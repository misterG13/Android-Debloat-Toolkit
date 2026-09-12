# Debloat — OnePlus Apps (OnePlus 9 Pro, OxygenOS 11)

OnePlus-package bloatware baked into the OS. All are non-essential to SMS /
calls / internet browsing. Sourced from [debloat-list.md](debloat-list.md).

> Does **not** include keepers like `OPLauncher2` (home screen), `OPSystemUI`,
> `OPSettingsProvider`, `oneplus-framework-res`, `OPCommunicationData`, or the
> communication/`com.oneplus.communication.data` messaging component and
> `com.oneplus.sms.smscplugger` — those are in the Keep list.

## Table

| Package dir | Package id | Note |
|-------------|-----------|------|
| Account | `com.oneplus.account` | OnePlus account & cloud sync |
| BackupRestoreRemoteService | `com.oneplus.backuprestore.remoteservice` | OnePlus backup/restore remote |
| OnePlus Switch | `com.oneplus.backuprestore` | Local data backup/transfer (`/system/reserve/OPBackupRestore`) |
| BTtestmode | `com.oneplus.bttestmode` | BT factory test mode |
| By_3rd_OPCotaApplication | `com.oneplus.cota` | OnePlus OTA updater — keep only if you want OTA updates |
| Calculator | `com.oneplus.calculator` | OnePlus calculator |
| EngineeringMode | `com.oneplus.factorymode` | OnePlus engineering mode |
| EngSpecialTest | `com.oneplus.factorymode.specialtest` | Factory special test |
| OnePlus Notes | `com.oneplus.note` | Notes app (`/system/reserve/OPNote`) |
| OnePlus Recorder | `com.oneplus.soundrecorder` | Voice/screen recorder (`/system/reserve/OPSoundRecorder`) |
| OnePlus Weather | `net.oneplus.weather` | Weather app (`/system/reserve/Weather`) |
| OnePlusGallery | `com.oneplus.gallery` | Photos gallery app |
| OnePlusWizard | `com.oneplus.setupwizard` | OnePlus setup wizard (OxygenOS 11 persisted) |
| OPAppCategoryProvider | `net.oneplus.provider.appcategoryprovider` | App categorization |
| OPAppLocker | `com.oneplus.applocker` | App Locker (privacy vault) |
| OPAccessoryFramework | `com.oneplus.accessory` | OnePlus accessory framework |
| OPAod | `com.oneplus.aod` | Always-On Display |
| OPBackup | `com.oneplus.opbackup` | OnePlus cloud backup |
| OPBreathMode | `com.oneplus.brickmode` | "Brick" breath-mode LED |
| OnePlus Store | `com.oneplus.store` | App store (overseas) (`/system/reserve/By_3rd_OnePlusStoreOverSeas`) |
| OPBugReportLite | `com.oneplus.opbugreportlite` | Bug-report uploader |
| OPCommonLogTool | `net.oneplus.commonlogtool` | Common log tool |
| OPDataOptimization | `com.oneplus.dataoptimization` | Data-saver "optimization" |
| OPDeskClock | `com.oneplus.deskclock` | OnePlus Clock app |
| OPDeviceManager | `net.oneplus.odm` | OnePlus device manager |
| OPDeviceManagerProvider | `net.oneplus.odm.provider` | OnePlus device manager provider |
| OPEngMode | `com.oneplus.engmode` | OnePlus engineering mode |
| OPFaceUnlock | `com.oneplus.faceunlock` | Face unlock |
| OPFilemanager | `com.oneplus.filemanager` | OnePlus File Manager |
| OPGamingSpace | `com.oneplus.gamespace` | OnePlus Game Space (gaming mode) |
| OPGeoIpTime | `com.oneplus.geoiptime` | Geofence time-zone service |
| OPLiveWallpaper | `com.oneplus.wallpaper` | OnePlus live/animated wallpapers |
| OPLongShot | `com.oneplus.screenshot` | Scrolling screenshot ("Long Shot") |
| OPMinidumpOptimization | `com.oneplus.minidumpoptimization` | Crash minidump upload |
| OPOnlineConfig | `com.oneplus.config` | Remote config service |
| OnePlus Community | `net.oneplus.forums` | Community forum app (`/system/reserve/OPForum`) |
| OPPush | `net.oneplus.push` | OnePlus push notifications |
| OPScreenRecord | `com.oneplus.screenrecord` | Screen recorder |
| OPSoundTuner | `com.oneplus.sound.tuner` | Sound tuner/EQ |
| OPTelephonyDiagnoseManager | `com.oneplus.diagnosemanager` | Telephony diagnostics |
| OPTelephonyOptimization | `com.oneplus.telephonyoptimization` | Telephony "optimizer" |
| OPWifiApSettings | `com.oneplus.wifiapsettings` | OnePlus Wi-Fi AP settings |
| oem_tcma | `cn.oneplus.oemtcma` | OnePlus icon pack / OEM theme |
| PhotosOnline | `cn.oneplus.photos` | OnePlus cloud Photos sync |

## Disable commands (on-device)

```bash
adb shell pm disable-user --user 0 com.oneplus.account
adb shell pm disable-user --user 0 com.oneplus.backuprestore.remoteservice
adb shell pm disable-user --user 0 com.oneplus.backuprestore
adb shell pm disable-user --user 0 com.oneplus.bttestmode
adb shell pm disable-user --user 0 com.oneplus.cota
adb shell pm disable-user --user 0 com.oneplus.calculator
adb shell pm disable-user --user 0 com.oneplus.factorymode
adb shell pm disable-user --user 0 com.oneplus.factorymode.specialtest
adb shell pm disable-user --user 0 com.oneplus.note
adb shell pm disable-user --user 0 com.oneplus.soundrecorder
adb shell pm disable-user --user 0 net.oneplus.weather
adb shell pm disable-user --user 0 com.oneplus.gallery
adb shell pm disable-user --user 0 com.oneplus.setupwizard
adb shell pm disable-user --user 0 net.oneplus.provider.appcategoryprovider
adb shell pm disable-user --user 0 com.oneplus.applocker
adb shell pm disable-user --user 0 com.oneplus.accessory
adb shell pm disable-user --user 0 com.oneplus.aod
adb shell pm disable-user --user 0 com.oneplus.opbackup
adb shell pm disable-user --user 0 com.oneplus.brickmode
adb shell pm disable-user --user 0 com.oneplus.store
adb shell pm disable-user --user 0 com.oneplus.opbugreportlite
adb shell pm disable-user --user 0 net.oneplus.commonlogtool
adb shell pm disable-user --user 0 com.oneplus.dataoptimization
adb shell pm disable-user --user 0 com.oneplus.deskclock
adb shell pm disable-user --user 0 net.oneplus.odm
adb shell pm disable-user --user 0 net.oneplus.odm.provider
adb shell pm disable-user --user 0 net.oneplus.forums
adb shell pm disable-user --user 0 com.oneplus.engmode
adb shell pm disable-user --user 0 com.oneplus.faceunlock
adb shell pm disable-user --user 0 com.oneplus.filemanager
adb shell pm disable-user --user 0 com.oneplus.gamespace
adb shell pm disable-user --user 0 com.oneplus.geoiptime
adb shell pm disable-user --user 0 com.oneplus.wallpaper
adb shell pm disable-user --user 0 com.oneplus.screenshot
adb shell pm disable-user --user 0 com.oneplus.minidumpoptimization
adb shell pm disable-user --user 0 com.oneplus.config
adb shell pm disable-user --user 0 net.oneplus.push
adb shell pm disable-user --user 0 com.oneplus.screenrecord
adb shell pm disable-user --user 0 com.oneplus.sound.tuner
adb shell pm disable-user --user 0 com.oneplus.diagnosemanager
adb shell pm disable-user --user 0 com.oneplus.telephonyoptimization
adb shell pm disable-user --user 0 com.oneplus.wifiapsettings
adb shell pm disable-user --user 0 cn.oneplus.oemtcma
adb shell pm disable-user --user 0 cn.oneplus.photos
```

> **Uninstall for storage** instead (OnePlus reserve apps restore via
> `cmd package install-existing`):
> `adb shell pm uninstall --user 0 net.oneplus.weather`
> `adb shell pm uninstall --user 0 com.oneplus.soundrecorder`
> `adb shell pm uninstall --user 0 com.oneplus.note`

## Related
- [Debloat — full list](debloat-list.md)
- [Debloat — Google apps](debloat-google.md)
