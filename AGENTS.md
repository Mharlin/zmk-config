# AGENTS.md - zmk-config (Piantor Pro BT, 36-key)

## What this is
ZMK firmware config for a Keebart **Piantor Pro BT, 36-key (5-column)** wireless split keyboard. The keymap is a port of the owner's QMK Kyria keymap (`keyboards/splitkb/kyria/keymaps/mharlin` in the `mharlin/qmk_firmware` fork): Colemak-DH, home row mods, 8 layers (Base, Nav, Mouse, Button, Num, Sym, Fun, Media).

## Layout
- `config/piantor_pro_bt_5col.keymap` - the keymap (edit this)
- `config/piantor_pro_bt_5col.conf` - Kconfig options (pointing, sleep, BT power)
- `boards/` - vendor board definitions + `sharp_mip` display shield, copied from keebart/zmk-config. Don't edit unless necessary.
- `build.yaml` - CI build matrix: `piantor_pro_bt_5col_left/right` + `sharp_mip`, and `settings_reset` for each half.

## Git remotes
- `origin` = `Mharlin/zmk-config` (push here, branch `main`)
- `upstream` = `keebart/zmk-config` (vendor; fetch only; history is unrelated, so merge with `--allow-unrelated-histories` and keep local keymap files)
- With `gh`, always pass `-R Mharlin/zmk-config`; the default repo may resolve to the old upstream template.

## Building
- GitHub Actions: `gh workflow run "Build ZMK firmware" -R Mharlin/zmk-config`, then `gh run watch <id> -R Mharlin/zmk-config` and `gh run download <id> -R Mharlin/zmk-config`. ~3 min. Artifacts are the `.uf2` files.
- Local build (tested, verified byte-identical to CI): `scripts/build-firmware.sh` runs the same build in Docker (`zmkfirmware/zmk-build-arm:stable`), reading `build.yaml` via `scripts/zmk_matrix.py`.
  - Needs Docker running and python3. First run downloads ZMK + Zephyr (~1 GB, several minutes, more if any Zephyr HAL repo fetch is flaky and needs a retry) into `.build/` (gitignored, never commit it).
  - Flags: `--update` forces `west update`, `--clean` wipes `.build/` and rebuilds from scratch.
  - Output: `.build/firmware/*.uf2` (left/right + settings_reset). Confirmed `cmp`-identical to the artifacts from the matching GitHub Actions run.
  - Two container quirks the script works around: (1) `west update` hits a git "dubious ownership" error on the bind-mounted repo, fixed by `git config --global --add safe.directory '*'` on every container invocation; (2) `west zephyr-export` registers the Zephyr CMake package under `$HOME`, which doesn't persist across `--rm` containers unless `$HOME` is bind-mounted too (`.build/container-home/`) — without that, `west build` fails with `find_package(Zephyr)` not found.

## Flashing (status: NOT yet flashed with the latest firmware)
Flashing needs USB (the bootloader is a USB drive; no flashing over Bluetooth).
1. Plug a half in with a USB-C **data** cable.
2. Double-press the small reset button on the back of the PCB quickly. A drive (NICENANO or similar) mounts.
3. Copy the half's `.uf2` onto it; the drive disappears and the half reboots.
4. Order: left half (central) first, then right.
- First time or pairing trouble: flash `*_settings_reset.uf2` to **both** halves, then the normal files.
- The keyboard was already connected over Bluetooth with the earlier firmware. Latest firmware (with bootloader keys) has not been flashed: the previous computer would not mount the USB drive. Latest `.uf2` files: download from the most recent successful Actions run.
- Once running the latest firmware, enter the bootloader from the keyboard: hold the Esc thumb (Media layer) and press the Q-position key (left half) or the M-position key (right half). It resets the half the key is on.

## Things to verify on hardware (nothing here was tested on the real keyboard)
- Home row mods (hold-tap `balanced`, 200 ms) and thumb layer-taps
- Å/Ä/Ö on the Num layer (macOS Option+U dead key; shifted variants release shift first)
- Double-tap Del sends F13 (Karabiner maps F13 -> Fn); hold Del = Fun layer
- Mouse move/scroll/click keys (`CONFIG_ZMK_POINTING=y`)
- App launcher macros on the Nav layer (Cmd+Space, wait 200 ms, type name, Enter)
- Bluetooth profiles: Fun layer, top row of right half (BT 1-4); M-position on the middle row clears the current profile

## Conventions
- Keep README.md in sync with keymap/config changes.
- Tap-dance layer-lock keys: single tap does nothing, double tap = `&to <layer>`.
- Don't commit `*.uf2` (gitignored by the template).
