# Debloat — Google Apps (OnePlus 9 Pro, OxygenOS 11)

Google-package bloatware baked into, or preloaded alongside, the OS. All are
non-essential to SMS / calls / internet browsing. Sourced from
[debloat-list.md](debloat-list.md) — see there for the full Keep/skip rationale.

> Includes `com.google.*` packages plus Chrome (`com.android.chrome`, a Google
> app). `WebViewGoogle` / `TrichromeLibrary` / `GmsCore` / `Play Store` are
> **not** here — they're in the Keep list (needed for web rendering and app
> installs).

## Table

| Package dir | Package id | Note |
|-------------|-----------|------|
| ARCore_stub | `com.google.ar.core` | AR services (camera depth/ARCore) |
| AndroidAutoStub | `com.google.android.projection.gearhead` | Android Auto stub |
| Chrome | `com.android.chrome` | Chrome browser (WebViewGoogle stays) |
| Drive | `com.google.android.apps.docs` | Google Drive |
| Duo | `com.google.android.apps.tachyon` | Google Duo video calls |
| FilesGoogle | `com.google.android.apps.nbu.files` | Google Files app |
| Google One | `com.google.android.apps.subscriptions.red` | Google One — user-installed during setup |
| Google News | `com.google.android.apps.magazines` | Google News — user-installed during setup |
| Google Wallet | `com.google.android.apps.walletnfcrel` | Google Wallet — user-installed |
| GoogleAssistant | `com.google.android.apps.googleassistant` | Google Assistant |
| GoogleContacts | `com.google.android.contacts` | Google Contacts app |
| GoogleFeedback | `com.google.android.feedback` | "Send feedback" service |
| GoogleLocationHistory | `com.google.android.gms.location.history` | Google location history |
| GoogleOneTimeInitializer | `com.google.android.onetimeinitializer` | One-time Google init |
| GooglePrintRecommendationService | `com.google.android.printservice.recommendation` | Print-service recommendation |
| GoogleRestore | `com.google.android.apps.restore` | Google restore after factory reset |
| GoogleTTS | `com.google.android.tts` | Text-to-speech engine |
| LiveCaption | `com.google.android.as` | Live captions |
| Maps | `com.google.android.apps.maps` | Google Maps |
| OobConfig | `com.google.android.apps.work.oobconfig` | Work-profile out-of-box config |
| Photos | `com.google.android.apps.photos` | Google Photos (cloud sync) |
| SearchSelector | `com.google.android.apps.setupwizard.searchselector` | Search-on-app-switch |
| talkback | `com.google.android.marvin.talkback` | Accessibility screen reader |
| Velvet | `com.google.android.googlequicksearchbox` | Google app / search (the "Google" pill) |
| Videos | `com.google.android.videos` | Google Play Movies/TV |
| Wellbeing | `com.google.android.apps.wellbeing` | Digital Wellbeing |
| YouTube | `com.google.android.youtube` | YouTube |
| YTMusic | `com.google.android.apps.youtube.music` | YouTube Music |

## Disable commands (on-device)

```bash
adb shell pm disable-user --user 0 com.google.ar.core
adb shell pm disable-user --user 0 com.google.android.projection.gearhead
adb shell pm disable-user --user 0 com.android.chrome
adb shell pm disable-user --user 0 com.google.android.apps.docs
adb shell pm disable-user --user 0 com.google.android.apps.tachyon
adb shell pm disable-user --user 0 com.google.android.apps.nbu.files
adb shell pm disable-user --user 0 com.google.android.apps.subscriptions.red
adb shell pm disable-user --user 0 com.google.android.apps.magazines
adb shell pm disable-user --user 0 com.google.android.apps.walletnfcrel
adb shell pm disable-user --user 0 com.google.android.apps.googleassistant
adb shell pm disable-user --user 0 com.google.android.contacts
adb shell pm disable-user --user 0 com.google.android.feedback
adb shell pm disable-user --user 0 com.google.android.gms.location.history
adb shell pm disable-user --user 0 com.google.android.onetimeinitializer
adb shell pm disable-user --user 0 com.google.android.printservice.recommendation
adb shell pm disable-user --user 0 com.google.android.apps.restore
adb shell pm disable-user --user 0 com.google.android.tts
adb shell pm disable-user --user 0 com.google.android.as
adb shell pm disable-user --user 0 com.google.android.apps.maps
adb shell pm disable-user --user 0 com.google.android.apps.work.oobconfig
adb shell pm disable-user --user 0 com.google.android.apps.photos
adb shell pm disable-user --user 0 com.google.android.apps.setupwizard.searchselector
adb shell pm disable-user --user 0 com.google.android.marvin.talkback
adb shell pm disable-user --user 0 com.google.android.googlequicksearchbox
adb shell pm disable-user --user 0 com.google.android.videos
adb shell pm disable-user --user 0 com.google.android.apps.wellbeing
adb shell pm disable-user --user 0 com.google.android.youtube
adb shell pm disable-user --user 0 com.google.android.apps.youtube.music
```

> **Uninstall instead** for user-installed One/News/Wallet to free storage:
> `adb shell pm uninstall --user 0 <pkg>` (reinstall from Play Store).
> `com.google.android.apps.work.oobconfig` is a protected package and can't be
> disabled via shell.

## Related
- [Debloat — full list](debloat-list.md)
- [Debloat — OnePlus apps](debloat-oneplus.md)
