# Android-Debloat-Toolkit

A toolkit to disable, uninstall, restore, and extract lists of Android APKs to debloat from your device.

## Features
- Disable, uninstall, or restore APKs
- Debloat and restore from export-format JSON lists
- Extract all APK filenames & locations from your system image to JSON
- Audit log of every action in `logs/`
- Target a specific device with `ADB_SERIAL=<serial>`
- Works on Linux Debian 12 systems
- Plans to adapt code for more Linux and Windows compatibility

## Prerequisites
- ADB installed on your system (`adb` on PATH)
- `jq` installed for parsing JSON lists
- `clear` (ncurses) for the menu interface
- USB debugging enabled on your Android device

## Installation
1. Clone the repository:
    ```
    git clone https://github.com/misterG13/Android-Debloat-Toolkit.git
    ```
2. Change to the cloned directory:
   ```
   cd Android-Debloat-Toolkit
   ```
3. Make the script executable (optional; `bash` works too):
   ```
   chmod +x android-debloat-toolkit.sh
   ```

## Usage
Run the script with:
  ```
  bash android-debloat-toolkit.sh
  ```
The script resolves its own location, so it can be run from any directory.

If more than one authorized device is connected, set `ADB_SERIAL` to target one:
  ```
  ADB_SERIAL=<serial> bash android-debloat-toolkit.sh
  ```

## Workflow
1. **Connect your Android device to your computer**
   - Make sure USB debugging is enabled on your device
2. **Run the script**
   - The script will guide you through the process of debloating your device
3. **Choose the operation**
   - Disable, uninstall, or restore APKs
   - Debloat or Restore reads a JSON list from `lists/exported/` (pick one if several exist)
4. **Choose a confirmation mode**
   - Confirm each APK, apply to all, or exit
5. **Actions are logged**
   - Every disable/uninstall/restore is written to `logs/debloat-<timestamp>.log`

## Project layout
```
android-debloat-toolkit.sh   # entry point: sources lib/, checks device, shows menu
lib/
  common.sh    # shared helpers, adb wrapper, device check
  lists.sh     # load export-format JSON lists, pick a JSON list
  packages.sh  # package state caching and validation
  log.sh       # audit logging
  removal.sh   # debloat actions
  restore.sh   # restore actions
  export.sh    # export the device's APK list to JSON
  menus.sh     # menu navigation
lists/exported/  # JSON lists used by Debloat/Restore
logs/          # audit logs (created on first debloat action)
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MPL-2.0](https://github.com/misterG13/Android-Debloat-Toolkit/tree/main?tab=MPL-2.0-1-ov-file#readme)