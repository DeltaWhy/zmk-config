#!/usr/bin/env bash
set -eEuo pipefail

if [[ ! -d .venv ]]
then
	uv venv .venv
fi

source .venv/bin/activate
uv pip install west

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <SHIELD> <BOARD>" >&2
	exit 1
fi

SHIELD="$1"
BOARD="$2"
shift 2
EXTRA_ARGS=("$@")
declare -p EXTRA_ARGS

TMPDIR="$(mktemp -d)"
# trap "rm -rf $TMPDIR" EXIT
mkdir "$TMPDIR/zephyr"
ln -s "$PWD/zephyr/module.yml" "$TMPDIR/zephyr"
ln -s "$PWD/boards" "$PWD/config" "$PWD/ardux.dtsi" "$TMPDIR"
ls -l "$TMPDIR"

west build -s zmk/app -d "build/${SHIELD}_${BOARD}" -b "${BOARD}" -- -DZMK_CONFIG="${PWD}/config" -DSHIELD="${SHIELD}" -DZMK_EXTRA_MODULES="$TMPDIR" "${EXTRA_ARGS[@]}"
