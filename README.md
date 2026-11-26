# ZMK config - Piantor Pro BT

Port of my QMK Kyria keymap (Colemak-DH, home row mods, 8 layers) to ZMK.

- Keymap: `config/piantor_pro_bt.keymap`, options: `config/piantor_pro_bt.conf`
- Board definition (copied from [datapointchris/zmk-config-piantor-pro-bt](https://github.com/datapointchris/zmk-config-piantor-pro-bt), MIT): `boards/arm/piantor_pro_bt`
- Build: push, then download the `.uf2` artifacts from the GitHub Actions run.
- Flash: double-tap reset on a half, drag the matching `.uf2` onto the drive that appears. First time (or if halves won't pair), flash the `*_settings_reset` file to both halves, then the normal files.
- Bluetooth: Fun layer, top row of the right half: BT 1-4 select profile, far-right corner key clears the current profile.
- Double-tap Del sends F13 (map F13 to Fn in Karabiner-Elements).
