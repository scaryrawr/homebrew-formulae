import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FORMULA = ROOT / "Formula/omlx.rb"
HARNESS = ROOT / "tests/omlx_formula_harness.rb"
KERNELS = {
    "attention": "omlx_attention_kernels",
    "lowbit": "omlx_lowbit_kernels",
    "quant_matmul": "omlx_quant_matmul_kernels",
    "sparse_index": "omlx_sparse_index_kernels",
}


class OmlxFormulaTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="omlx formula ")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for kernel in KERNELS:
            source = self.root / "source/omlx/custom_kernels" / kernel / "csrc"
            source.mkdir(parents=True)
            (source / "bindings.cpp").touch()
            (source / "kernels.metal").touch()
        (self.root / "model.whl").touch()
        self.metal = (
            self.root / "home/Library/Developer/DVTDownloads/MetalToolchain/"
            "mounts/test/Metal.xctoolchain/usr/bin/metal"
        )
        self.metal.parent.mkdir(parents=True)
        self.metal.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$@"\nexit "${METAL_EXIT:-0}"\n'
        )
        self.metal.chmod(0o755)

    def run_formula(self, method="install", options="grammar,audio,custom-kernel",
                    compiler="native", formula=FORMULA, **extra_env):
        env = {
            **os.environ,
            "TEST_ROOT": str(self.root),
            "TEST_OPTIONS": options,
            "TEST_COMPILER": compiler,
            "OMLX_WITH_CUSTOM_KERNEL": "",
            "CMAKE_ARGS": "",
            **extra_env,
        }
        result = subprocess.run(
            ["ruby", str(HARNESS), str(formula), method],
            env=env, capture_output=True, text=True,
        )
        output = result.stdout if result.returncode == 0 else result.stderr
        return result, json.loads(output.splitlines()[-1])

    def test_modern_layout_and_requested_options(self):
        result, state = self.run_formula()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["custom_kernel"], "1")
        self.assertEqual(state["cmake_args"], "")
        commands = state["commands"]
        self.assertEqual(commands[0][1:3], ["-m", "venv"])
        self.assertEqual(commands[1], [
            str(self.root / "prefix/libexec/bin/pip"), "install",
            str(self.root / "source") + "[grammar]",
        ])
        self.assertIn("misaki>=0.9.4", commands[3])
        self.assertEqual(commands[4][-3:], ["install", "--no-deps", "."])
        self.assertIn(
            [str(self.root / "prefix/libexec/bin/pip"), "check"], commands,
        )
        self.assertEqual(
            (self.root / "prefix/libexec/post-install-fixups").read_text(),
            "grammar\ncustom-kernel",
        )
        self.assertEqual(
            (self.root / "prefix/libexec/post-install-custom-kernels")
            .read_text().splitlines(),
            list(KERNELS),
        )
        shim = self.root / "source/homebrew-toolchain/xcrun"
        self.assertTrue(shim.is_file())
        self.assertEqual(state["path"].split(os.pathsep)[0], str(shim.parent))

    def test_absent_and_moved_required_kernels_fail_before_venv(self):
        for kernel in KERNELS:
            source = self.root / "source/omlx/custom_kernels" / kernel / "csrc"
            moved = source.with_name("moved")
            source.rename(moved)
            try:
                result, state = self.run_formula()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(str(source / "bindings.cpp"), state["error"])
                self.assertEqual(state["commands"], [])
            finally:
                moved.rename(source)

    def test_missing_metal_sources_fail_explicitly(self):
        source = self.root / "source/omlx/custom_kernels/attention/csrc"
        (source / "kernels.metal").unlink()
        result, state = self.run_formula()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Metal sources in {source}", state["error"])
        self.assertEqual(state["commands"], [])

    def test_no_usable_compiler_fails_before_venv(self):
        result, state = self.run_formula(compiler="missing")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Metal compiler not found", state["error"])
        self.assertEqual(state["commands"], [])

    def test_missing_xcode_fails_before_venv(self):
        result, state = self.run_formula(TEST_XCODE="missing")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires full Xcode", state["error"])
        self.assertEqual(state["commands"], [])

    def test_default_install_does_not_require_kernel_sources_or_toolchain(self):
        shutil.rmtree(self.root / "source/omlx/custom_kernels")
        result, state = self.run_formula(options="", compiler="missing")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["custom_kernel"], "")
        self.assertFalse((self.root / "source/homebrew-toolchain").exists())
        self.assertEqual(state["commands"][1][-1], str(self.root / "source"))

    def test_homebrew_pip_index_is_forwarded_without_using_uv_settings(self):
        result, state = self.run_formula(
            HOMEBREW_PIP_INDEX_URL="https://brew.example/simple/",
            PIP_INDEX_URL="https://pip.example/simple/",
            UV_DEFAULT_INDEX="https://uv.example/simple/",
            PIP_FIND_LINKS=str(self.root / "wheelhouse"),
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["pip_index"], "https://brew.example/simple/")
        self.assertEqual(state["pip_find_links"], str(self.root / "wheelhouse"))
        # With no Homebrew override, pip retains its own index, not uv's.
        shutil.rmtree(self.root / "prefix")
        result, state = self.run_formula(
            options="", HOMEBREW_PIP_INDEX_URL="",
            PIP_INDEX_URL="https://pip.example/simple/",
            UV_DEFAULT_INDEX="https://uv.example/simple/",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["pip_index"], "https://pip.example/simple/")

    def test_homebrew_wheelhouse_survives_scrubbed_pip_environment(self):
        wheelhouse = str(self.root / "verified-wheels")
        result, state = self.run_formula(
            HOMEBREW_PIP_FIND_LINKS=wheelhouse, PIP_FIND_LINKS="",
            HOMEBREW_PIP_INDEX_URL="https://proxy.example/simple/",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["pip_find_links"], wheelhouse)
        self.assertEqual(state["pip_index"], "https://proxy.example/simple/")

    def test_homebrew_wheelhouse_takes_precedence_over_pip_environment(self):
        result, state = self.run_formula(
            HOMEBREW_PIP_FIND_LINKS="file:///verified/wheels",
            PIP_FIND_LINKS="file:///different/wheels",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["pip_find_links"], "file:///verified/wheels")

    def test_fallback_shim_routes_metal_and_propagates_failure(self):
        result, _ = self.run_formula(method="setup_custom_kernels",
                                     compiler="fallback")
        self.assertEqual(result.returncode, 0, result.stderr)
        shim = self.root / "source/homebrew-toolchain/xcrun"
        for exit_code in (0, 23):
            run = subprocess.run(
                [str(shim), "-sdk", "macosx", "metal", "-c", "file with space"],
                env={**os.environ, "METAL_EXIT": str(exit_code)},
                text=True, capture_output=True,
            )
            self.assertEqual(run.returncode, exit_code)
            self.assertEqual(run.stdout.splitlines(), ["-c", "file with space"])

    def test_requested_options_install_with_mounted_fallback(self):
        result, state = self.run_formula(compiler="fallback")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(state["custom_kernel"], "1")
        metal = self.root / "source/homebrew-toolchain/metal"
        self.assertEqual(metal.resolve(), self.metal.resolve())

    def test_shim_rejects_unsupported_metal_forms(self):
        result, _ = self.run_formula(method="setup_custom_kernels")
        self.assertEqual(result.returncode, 0, result.stderr)
        shim = self.root / "source/homebrew-toolchain/xcrun"
        for args in (["metal", "-help"], ["--find", "metal"],
                     ["-sdk", "iphoneos", "metal", "-help"]):
            run = subprocess.run([str(shim), *args], capture_output=True,
                                 text=True)
            self.assertEqual(run.returncode, 64)
            self.assertIn("Unsupported", run.stderr)

    def selected_developer_environment(self):
        env = os.environ.copy()
        if not env.get("DEVELOPER_DIR"):
            selected = subprocess.run(
                ["/usr/bin/xcode-select", "-p"], check=True,
                capture_output=True, text=True,
            )
            env["DEVELOPER_DIR"] = selected.stdout.strip()
        return env

    def test_harness_accepts_renamed_xcode_without_installing_it(self):
        developer_dir = "/Applications/Xcode Custom.app/Contents/Developer"
        result, _ = self.run_formula(
            method="setup_custom_kernels", TEST_DEVELOPER_DIR=developer_dir,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        metal = self.root / "source/homebrew-toolchain/metal"
        command = shlex.split(metal.read_text().splitlines()[1])
        self.assertIn(f"DEVELOPER_DIR={developer_dir}", command)

    def test_native_shim_and_non_metal_forwarding(self):
        if sys.platform != "darwin":
            self.skipTest("requires the macOS xcrun tool")
        env = self.selected_developer_environment()
        result, _ = self.run_formula(
            method="setup_custom_kernels",
            TEST_DEVELOPER_DIR=env["DEVELOPER_DIR"],
            DEVELOPER_DIR=env["DEVELOPER_DIR"],
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        shim = self.root / "source/homebrew-toolchain/xcrun"
        metal = subprocess.run(
            [str(shim), "-sdk", "macosx", "metal", "-help"],
            capture_output=True, text=True, env=env,
        )
        direct_metal = subprocess.run(
            ["/usr/bin/xcrun", "-sdk", "macosx", "metal", "-help"],
            capture_output=True, text=True, env=env,
        )
        self.assertEqual(metal.returncode, direct_metal.returncode)
        for args in (["-sdk", "macosx", "--show-sdk-version"],
                     ["--omlx-invalid-option"]):
            direct = subprocess.run(["/usr/bin/xcrun", *args],
                                    capture_output=True, text=True, env=env)
            adapted = subprocess.run([str(shim), *args], capture_output=True,
                                     text=True, env=env)
            self.assertEqual(adapted.returncode, direct.returncode)
            self.assertEqual(adapted.stdout, direct.stdout)

    def test_native_adapter_compiles_and_links_real_metal(self):
        if sys.platform != "darwin":
            self.skipTest("requires the macOS Metal compiler")
        env = self.selected_developer_environment()
        probe = subprocess.run(
            ["/usr/bin/xcrun", "-sdk", "macosx", "metal", "-help"],
            capture_output=True, env=env,
        )
        if probe.returncode:
            self.skipTest("Metal compiler is not installed")
        result, _ = self.run_formula(
            method="setup_custom_kernels",
            TEST_DEVELOPER_DIR=env["DEVELOPER_DIR"],
            DEVELOPER_DIR=env["DEVELOPER_DIR"],
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        shim = self.root / "source/homebrew-toolchain/xcrun"
        source = self.root / "smoke.metal"
        source.write_text(
            "#include <metal_stdlib>\n"
            "kernel void omlx_smoke(device float *out [[buffer(0)]], "
            "uint i [[thread_position_in_grid]]) { out[i] = 1.0f; }\n"
        )
        air = self.root / "smoke.air"
        metallib = self.root / "smoke.metallib"
        for args in (["-c", str(source), "-o", str(air)],
                     [str(air), "-o", str(metallib)]):
            run = subprocess.run(
                [str(shim), "-sdk", "macosx", "metal", *args],
                capture_output=True, text=True, env=env,
            )
            self.assertEqual(run.returncode, 0, run.stderr)
        self.assertGreater(metallib.stat().st_size, 0)

    def test_all_native_checks_require_metallib_and_abi(self):
        result, state = self.run_formula()
        self.assertEqual(result.returncode, 0, result.stderr)
        code = state["commands"][2][-1]
        packages = self.root / "packages/omlx/custom_kernels"
        for kernel, library in KERNELS.items():
            package = packages / kernel
            package.mkdir(parents=True)
            (package / "fast.py").write_text(
                "def is_native_available(): return True\n"
                "def import_error(): return None\n"
            )
            (package / f"{library}.metallib").touch()
        env = {**os.environ, "PYTHONPATH": str(self.root / "packages"),
               "PYTHONDONTWRITEBYTECODE": "1"}

        def verify():
            return subprocess.run([sys.executable, "-c", code], env=env,
                                  cwd=self.root, capture_output=True, text=True)

        self.assertEqual(verify().returncode, 0)
        for kernel, library in KERNELS.items():
            metallib = packages / kernel / f"{library}.metallib"
            metallib.unlink()
            failed = verify()
            self.assertNotEqual(failed.returncode, 0)
            self.assertIn(str(metallib), failed.stderr)
            metallib.touch()
        for kernel in KERNELS:
            fast = packages / kernel / "fast.py"
            working = fast.read_text()
            fast.write_text(
                "def is_native_available(): return False\n"
                "def import_error(): return 'ABI mismatch'\n"
            )
            failed = verify()
            self.assertNotEqual(failed.returncode, 0)
            self.assertIn(kernel, failed.stderr)
            self.assertIn("ABI mismatch", failed.stderr)
            fast.write_text(working)


if __name__ == "__main__":
    unittest.main()
