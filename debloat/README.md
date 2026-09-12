## Debloat docs

Curated reference for the OnePlus 9 Pro (OxygenOS 11): what's removable and what
must stay.

| File | Scope |
|------|-------|
| `debloat-list.md` | Master list — every baked-in bloat APK grouped by partition, plus the Keep list (breaking SMS/calls/browsing if removed) |
| `debloat-google.md` | Google-package bloat only, with ready `pm disable-user` commands |
| `debloat-oneplus.md` | OnePlus-package bloat only, with ready `pm disable-user` commands |

These are static guides for deciding what to remove; the toolkit itself reads
JSON lists from `lists/exported/` or the curated `lists/customized/` (see
`lists/README.md`, `lists/exported/README.md`, `lists/customized/README.md`).
The curated lists are generated from these docs.

Notes:
- "Bloat" here means removable without breaking SMS, calls, or the browser —
  always consult the Keep list in `debloat-list.md` first.
- Target is OnePlus 9 Pro on OxygenOS 11; package dirs/ids vary by OEM and ROM.
- Disable with `adb shell pm disable-user --user 0 <pkg>`; uninstall with
  `adb shell pm uninstall --user 0 <pkg>` to free storage.