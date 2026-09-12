### APK export lists are saved here

Files are produced by the **Export Phone's APK List** menu option
(`apkExport` in `lib/export.sh`).

Naming: `apk_list_<model>.json` for a full export, or
`apk_list_<model>_<search>.json` when a keyword is used
(e.g. `apk_list_LE2127_google.json`).

Each file is an array of JSON objects with:
- `id`          - Android package name
- `list`        - `"unknown"` at export time; set it when curating
- `description` - `"Version: <v>, Directory: <path>"` from the device
- `status`      - `"enabled"`/`"disabled"` reflecting device state at export
- `removal`     - `"unknown"` at export time; set it when curating

Debloat and Restore read their lists from this directory
(`selectJSONList` in `lib/lists.sh`). To curate a list, copy a file here,
set `list`, `removal`, and a meaningful `description`, and drop entries to skip.
See `lists/README.md` for the schema.

The exported lists are generated output and git-ignored; only this README
is tracked.