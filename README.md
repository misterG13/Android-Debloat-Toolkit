# Android-Debloat-Toolkit

A toolkit to disable, uninstall, restore, and extract lists of Android APKs to debloat from your device.

## Table of Contents
* [Features](#features)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [Workflow](#workflow)
* [Contributing](#contributing)
* [License](#license)

## Features
- Disable, uninstall, or restore APKs
- Easily customize lists of APKs to debloat
- Extract all APK filenames & locations from your system image
- Works on Linux Debian 12 systems
- Plans to adapt code for more Linux and Windows compatibility

## Prerequisites
- ADB and Fastboot installed on your system
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
3. Make the script executable:
   ```
   chmod +x adb-debloat-toolkit.sh
   ```

## Usage
Run the script with:
  ```
  bash adb-debloat-toolkit.sh
  ```

## Workflow
1. **Connect your Android device to your computer**
   - Make sure USB debugging is enabled on your device

2. **Run the script**
   - The script will guide you through the process of debloating your device

3. **Choose the operation**
   - Disable, uninstall, or restore APKs
   - Customize lists of APKs to debloat

4. **Confirm your selection**
   - The script will display a list of APKs that will be affected

5. **Wait for the script to finish**
   - The script will perform the selected operation and display the results

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MPL-2.0](https://github.com/misterG13/Android-Debloat-Toolkit/tree/main?tab=MPL-2.0-1-ov-file#readme)