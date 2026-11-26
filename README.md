# ZMK config - Piantor Pro BT

36-key (5-column) Piantor Pro BT. Port of my QMK Kyria keymap (Colemak-DH, home row mods, 8 layers) to ZMK.

- Keymap: `config/piantor_pro_bt_5col.keymap`, options: `config/piantor_pro_bt_5col.conf`
- Board definition + display shield (from [keebart/zmk-config](https://github.com/keebart/zmk-config), the vendor repo): `boards/`
- Build: push, then download the `.uf2` artifacts from the GitHub Actions run.
- Flash: double-tap reset on a half, drag the matching `.uf2` onto the drive that appears. First time (or if halves won't pair), flash the `*_settings_reset` file to both halves, then the normal files.
- Bluetooth: Fun layer, top row of the right half: BT 1-4 select profile, the key under the right-hand M position clears the current profile.
- Double-tap Del sends F13 (map F13 to Fn in Karabiner-Elements).
- Bootloader (no reset button needed): hold the Esc thumb (Media layer), then press the Q-position key to flash the left half or the M-position key to flash the right half. It resets the half the key sits on, so use the matching half's key.

## Local build
`scripts/build-firmware.sh` builds all targets from `build.yaml` in Docker (`zmkfirmware/zmk-build-arm:stable`) and writes `.uf2` files to `.build/firmware/` (gitignored). Needs Docker and python3; no local west/Zephyr SDK install required.

- First run clones ZMK + Zephyr into `.build/zmk-ws/` (several minutes, network-heavy); later runs reuse that workspace and are much faster.
- `--update`: re-run `west update` (e.g. after bumping `config/west.yml`).
- `--clean`: wipe `.build/` and start over.
- Output has been verified byte-for-byte identical to the GitHub Actions artifacts for the same commit.
