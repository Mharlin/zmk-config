# ZMK config - Piantor Pro BT

36-key (5-column) Piantor Pro BT. Port of my QMK Kyria keymap (Colemak-DH, home row mods, 8 layers) to ZMK.

- Keymap: `config/piantor_pro_bt_5col.keymap`, options: `config/piantor_pro_bt_5col.conf`
- Board definition + display shield (from [keebart/zmk-config](https://github.com/keebart/zmk-config), the vendor repo): `boards/`
- Build: push, then download the `.uf2` artifacts from the GitHub Actions run.
- Flash: double-tap reset on a half, drag the matching `.uf2` onto the drive that appears. First time (or if halves won't pair), flash the `*_settings_reset` file to both halves, then the normal files.
- Bluetooth: Fun layer, top row of the right half: BT 1-4 select profile, the key under the right-hand M position clears the current profile.
- Double-tap Del sends F13 (map F13 to Fn in Karabiner-Elements).
