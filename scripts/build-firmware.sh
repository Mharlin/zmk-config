#!/usr/bin/env bash
# Local ZMK firmware build, mirroring .github/workflows/build.yml (zmkfirmware's
# reusable build-user-config.yml@v0.3) using the zmk-build-arm Docker image.
#
# Usage:
#   scripts/build-firmware.sh            # build all targets in build.yaml
#   scripts/build-firmware.sh --update   # force `west update` before building
#   scripts/build-firmware.sh --clean    # wipe the west workspace and rebuild from scratch
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="zmkfirmware/zmk-build-arm:stable"
WORKSPACE_DIR="$REPO_ROOT/.build/zmk-ws"
BUILDS_DIR="$REPO_ROOT/.build/builds"
OUT_DIR="$REPO_ROOT/.build/firmware"
CONTAINER_HOME="$REPO_ROOT/.build/container-home"

FORCE_UPDATE=0
CLEAN=0
for arg in "$@"; do
  case "$arg" in
    --update) FORCE_UPDATE=1 ;;
    --clean) CLEAN=1 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

if [ "$CLEAN" -eq 1 ]; then
  echo "Removing $REPO_ROOT/.build ..."
  rm -rf "$REPO_ROOT/.build"
fi

mkdir -p "$WORKSPACE_DIR" "$BUILDS_DIR" "$OUT_DIR" "$CONTAINER_HOME"

MATRIX_PY="$REPO_ROOT/scripts/zmk_matrix.py"

echo "Build matrix:"
python3 "$MATRIX_PY" "$REPO_ROOT/build.yaml" describe

run_in_container() {
  # The repo is bind-mounted from macOS (owned by the host UID) but the
  # container runs as root, so git refuses the west-managed repos under
  # .build/zmk-ws as "dubious ownership" unless we allow them explicitly.
  # $HOME is also mounted persistently: `west zephyr-export` registers the
  # Zephyr CMake package there, and that registration must survive between
  # --rm container runs for later `west build` steps to find it.
  docker run --rm \
    -v "$REPO_ROOT:/workspace" \
    -v "$CONTAINER_HOME:/root" \
    -w /workspace \
    "$IMAGE" \
    bash -euc "git config --global --add safe.directory '*' && $1"
}

NEED_INIT=0
if [ ! -d "$WORKSPACE_DIR/.west" ]; then
  NEED_INIT=1
fi

echo "Syncing config into isolated west workspace..."
run_in_container "
  mkdir -p /workspace/.build/zmk-ws/config
  rm -rf /workspace/.build/zmk-ws/config/*
  cp -R /workspace/config/* /workspace/.build/zmk-ws/config/
"

if [ "$NEED_INIT" -eq 1 ]; then
  echo "Running west init (first run)..."
  run_in_container "cd /workspace/.build/zmk-ws && west init -l config"
  FORCE_UPDATE=1
fi

if [ "$FORCE_UPDATE" -eq 1 ]; then
  echo "Running west update (this fetches ZMK + Zephyr, can take a while on first run)..."
  run_in_container "cd /workspace/.build/zmk-ws && west update --fetch-opt=--filter=tree:0"
fi

if [ ! -d "$CONTAINER_HOME/.cmake/packages/Zephyr" ]; then
  echo "Running west zephyr-export (registers the Zephyr CMake package)..."
  run_in_container "cd /workspace/.build/zmk-ws && west zephyr-export"
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

python3 "$MATRIX_PY" "$REPO_ROOT/build.yaml" list | while IFS= read -r entry; do
  board="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["board"])' "$entry")"
  shield="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("shield",""))' "$entry")"
  artifact="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["artifact-name"])' "$entry")"

  build_dir="/workspace/.build/builds/${artifact}"
  shield_arg=""
  if [ -n "$shield" ]; then
    shield_arg="-DSHIELD=\"$shield\""
  fi

  echo "==> Building ${artifact} (board=${board} shield=${shield:-none})"
  run_in_container "
    cd /workspace/.build/zmk-ws
    west build -s zmk/app -d '${build_dir}' -b '${board}' -- \
      -DZMK_CONFIG=/workspace/.build/zmk-ws/config \
      ${shield_arg} \
      -DZMK_EXTRA_MODULES=/workspace
  "

  src="$BUILDS_DIR/$artifact/zephyr/zmk.uf2"
  if [ -f "$src" ]; then
    cp "$src" "$OUT_DIR/${artifact}.uf2"
    echo "    -> $OUT_DIR/${artifact}.uf2"
  else
    echo "    !! No zmk.uf2 produced for ${artifact} (check build log above)" >&2
    exit 1
  fi
done

echo
echo "Done. Firmware files in $OUT_DIR:"
ls -la "$OUT_DIR"
