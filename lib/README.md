## lib

Shared Bash modules sourced by the entry point `android-debloat-toolkit.sh` in this order:

1. `common.sh`   - shared helpers: `adb_cmd` (targets `ADB_SERIAL` when set), `getSerial`, `require`, `checkDevice`, `rebootAndroid`, `exitScript`; globals `PROJECT_DIR`, `ADB_SERIAL`
2. `lists.sh`    - JSON list handling: `loadJSON`, `selectJSONList`; globals `packages`, `LIST_FILE`
3. `packages.sh` - package state cache and helpers: `refreshPackageState`, `is_valid_package`, `json_escape`, `isPackageInstalled`, `isPackageCached`; globals `enabled_pkgs`, `disabled_pkgs`
4. `log.sh`      - audit logging: `initLog`, `writeLog`; globals `LOG_FILE`, `LOG_SERIAL`, `LOG_MODEL`
5. `removal.sh`  - debloat actions: `debloatList`, `apkRemoval`; global `SNAPSHOT_FILE`
6. `restore.sh`  - restore actions: `restoreList`, `apkRestore`
7. `export.sh`   - APK list export: `apkExport`
8. `menus.sh`    - menu UI: `mainMenu`