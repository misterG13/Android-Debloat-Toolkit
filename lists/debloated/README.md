### Per-device debloat snapshots (restore lists) are saved here

Each device gets its own subdirectory named after its ADB serial
(`lists/debloated/<serial>/`). On Debloat, the chosen JSON list from
`lists/exported/` is copied here as the device's snapshot.

The snapshot doubles as the Restore list: Debloat marks acted-on entries with
`"status": "disabled"` and the performed `removal` action. Restore reads this
same file (filtering on `disabled` entries), flips restored entries back to
`"status": "enabled"`, and clears their `removal`.

The per-device snapshots are generated output and git-ignored; only this README
is tracked.