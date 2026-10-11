#!/usr/bin/env bash
set -euo pipefail

stable_formulae() {
  if [[ -z "$1" ]]
  then
    return
  fi
  local formula result=""
  local -a formulae
  IFS=, read -r -a formulae <<<"$1"
  for formula in "${formulae[@]}"
  do
    case "${formula}" in
      "" | omlx | scaryrawr/formulae/omlx) continue ;;
      *) result="${result:+${result},}${formula}" ;;
    esac
  done
  printf '%s' "${result}"
}

testing_formulae="$(stable_formulae "${TESTING_FORMULAE?}")"
added_formulae="$(stable_formulae "${ADDED_FORMULAE?}")"
if [[ -n "${testing_formulae}" || -n "${DELETED_FORMULAE?}" ]]
then
  brew test-bot --only-formulae \
    --testing-formulae="${testing_formulae}" \
    --added-formulae="${added_formulae}" \
    --deleted-formulae="${DELETED_FORMULAE}"
fi

if [[ ",${TESTING_FORMULAE}," == *,omlx,* || ",${TESTING_FORMULAE}," == *,scaryrawr/formulae/omlx,* ]]
then
  if [[ "${RUNNER_OS?}" == "macOS" && "${RUNNER_ARCH?}" == "ARM64" ]]
  then
    brew install --HEAD --build-from-source scaryrawr/formulae/omlx
    brew test omlx
  else
    echo "Skipping head-only Apple Silicon formula omlx on ${RUNNER_OS}/${RUNNER_ARCH}"
  fi
fi
