## JSON lists

Debloat and Restore operate on export-format JSON lists placed in this directory.

Each file is an array of objects created by the toolkit's **Export Phone's APK List**
option. To curate a list, edit a copy of an export: keep the `id`, optionally set a
meaningful `list`, `description`, and `removal`, and drop the entries you want to skip.

Example entry:
```json
{
  "id": "com.google.android.gm",
  "list": "google",
  "description": "Gmail",
  "status": "enabled",
  "removal": "recommended"
}
```

Only the `id` is required. If exactly one JSON list is present it is used directly;
otherwise the script asks which list to use.