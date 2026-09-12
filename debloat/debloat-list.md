# Debloat List — OnePlus 9 Pro (OxygenOS 11.2.2.2, EU)

Extracted with `debugfs` directly from the partition images in `flash-files/`
(`system.img`, `product.img`, `system_ext.img`). Each row is an APK baked into
the read-only OS — not a user-installed app — so removing these cannot be undone
by an app uninstall; they return on the next ROM flash.

This list answers: **which baked-in OnePlus / Google / partner APKs are bloat —
non-essential to text messaging (SMS/MMS/RCS), phone calls, and internet
browsing?**

Partitions scanned (see [Parts of the Super Image](super-image-partitions.md)):
`system` (`/system/app`, `/system/priv-app`), `product` (`/app`, `/priv-app`),
`system_ext` (`/app`, `/priv-app`). Vendor and odm contain firmware/drivers and
hold no user-facing apps, so they are excluded. A few extra preloaded apps that
live outside these partitions (OnePlus `/system/reserve` + Google apps installed
during setup) are listed separately at the end of the bloat section.

> **Bloat caveat.** "Bloat" means *removable without breaking SMS, calls, or the
> browser* — it is not always "worthless". Several are OnePlus/Google features
> you may actually use (screen record, file manager, Photos, etc.). The
> **Keep** section at the end lists system components that look optional but
> will break telephony, messaging, or networking if removed.

## Bloat — safe to remove (non-essential to SMS / calls / browsing)

Bold flags the most aggressive, clearly-unneeded ones first in each partition.

### `system` → `/system/app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **ARCore_stub** | `com.google.ar.core` | AR services (camera depth/ARCore) |
| **BasicDreams** | `com.android.dreams.basic` | Default screensaver |
| **EasterEgg** | `com.android.egg` | Hidden easter egg |
| **LiveWallpapersPicker** | `com.android.wallpaper.livepicker` | Live wallpaper picker |
| **SensorTestTool** | `com.fingerprints.fingerprintsensortest` | Fingerprint sensor test tool |
| **Traceur** | `com.android.traceur` | System performance tracing |
| GooglePrintRecommendationService | `com.google.android.printservice.recommendation` | Print-service recommendation |
| PrintSpooler | `com.android.printspooler` | Printing framework UI (omit if you never print) |
| BluetoothMidiService | `com.android.bluetoothmidiservice` | BT MIDI instrument support |
| WallpaperBackup | `com.android.wallpaperbackup` | Wallpaper restore |

### `system` → `/system/priv-app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **DynamicSystemInstallationService** | `com.android.dynsystem` | DSU dynamic-system loader (dev/test) |
| **FilesGoogle** | `com.google.android.apps.nbu.files` | Google Files app — OnePlus ships its own file manager |
| QualcommVoiceActivation | `com.quicinc.voice.activation` | Voice-match activation |
| BuiltInPrintService | `com.android.bips` | Built-in printing |
| SoundPicker | `com.android.soundpicker` | Ringtone/notification sound picker |

### `product` → `/app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **Account** | `com.oneplus.account` | OnePlus account & cloud sync |
| **Chrome** | `com.android.chrome` | Chrome browser — WebViewGoogle stays, see Keep |
| **Drive** | `com.google.android.apps.docs` | Google Drive |
| **Duo** | `com.google.android.apps.tachyon` | Google Duo video calls |
| **GoogleAssistant** | `com.google.android.apps.googleassistant` | Google Assistant |
| **GoogleLocationHistory** | `com.google.android.gms.location.history` | Google location history |
| **Maps** | `com.google.android.apps.maps` | Google Maps |
| **Photos** | `com.google.android.apps.photos` | Google Photos (cloud sync) |
| **Videos** | `com.google.android.videos` | Google Play Movies/TV |
| **YTMusic** | `com.google.android.apps.youtube.music` | YouTube Music |
| **YouTube** | `com.google.android.youtube` | YouTube |
| Calculator | `com.oneplus.calculator` | OnePlus calculator |
| GoogleTTS | `com.google.android.tts` | Text-to-speech engine |
| GoogleContacts | `com.google.android.contacts` | Google Contacts app (system ContactsProvider stays) |
| PowerOffAlarm | `com.qualcomm.qti.poweroffalarm` | Power-off alarm (Scheduled power on/off) |
| talkback | `com.google.android.marvin.talkback` | Accessibility screen reader — keep if a11y users need it |

### `product` → `/priv-app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **AndroidAutoStub** | `com.google.android.projection.gearhead` | Android Auto stub |
| **HotwordEnrollmentOKGoogleHEXAGON** | `com.android.hotwordenrollment.okgoogle` | "OK Google" hotword |
| **HotwordEnrollmentXGoogleHEXAGON** | `com.android.hotwordenrollment.xgoogle` | "OK Google" hotword |
| **LiveCaption** | `com.google.android.as` | Live captions |
| **SearchSelector** | `com.google.android.apps.setupwizard.searchselector` | Search-on-app-switch |
| **Velvet** | `com.google.android.googlequicksearchbox` | Google app / search (the "Google" pill) |
| **Wellbeing** | `com.google.android.apps.wellbeing` | Digital Wellbeing |
| GoogleRestore | `com.google.android.apps.restore` | Google restore after factory reset |
| OobConfig | `com.google.android.apps.work.oobconfig` | Work-profile out-of-box config |

### `system_ext` → `/app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **BTtestmode** | `com.oneplus.bttestmode` | BT factory test mode |
| **By_3rd_NetflixActivationOverSeas** | `com.netflix.partner.activation` | Netflix partner activation |
| **By_3rd_NetflixStubOverSeas** | `com.netflix.mediaclient` | Netflix client |
| **By_3rd_PlayAutoInstallConfigOverSeas** | `android.autoinstalls.config.oneplus` | Carrier auto-download config |
| **EngSpecialTest** | `com.oneplus.factorymode.specialtest` | Factory special test |
| **EngineeringMode** | `com.oneplus.factorymode` | OnePlus engineering mode |
| **LogKitSdService** | `com.oem.logkitsdservice` | Log capture |
| **NFCTestMode** | `com.oem.nfc` | NFC test mode |
| **OPBugReportLite** | `com.oneplus.opbugreportlite` | Bug-report uploader |
| **OPCommonLogTool** | `net.oneplus.commonlogtool` | Common log tool |
| **OPEngMode** | `com.oneplus.engmode` | OnePlus engineering mode |
| **OPGamingSpace** | `com.oneplus.gamespace` | OnePlus Game Space (gaming mode) |
| **OPLiveWallpaper** | `com.oneplus.wallpaper` | OnePlus live/animated wallpapers |
| **OPLongShot** | `com.oneplus.screenshot` | Scrolling screenshot ("Long Shot") |
| **OPMinidumpOptimization** | `com.oneplus.minidumpoptimization` | Crash minidump upload |
| **OPPush** | `net.oneplus.push` | OnePlus push notifications |
| **OPScreenRecord** | `com.oneplus.screenrecord` | Screen recorder |
| **OPTelephonyDiagnoseManager** | `com.oneplus.diagnosemanager` | Telephony diagnostics |
| **OPTelephonyOptimization** | `com.oneplus.telephonyoptimization` | Telephony "optimizer" |
| **OemAutoTestServer** | `com.oem.autotest` | Factory auto-test |
| **PerformanceMode** | `com.qualcomm.qti.performancemode` | Gaming performance mode |
| **QColor** | `com.qualcomm.qti.qcolor` | Display color service |
| **QTIDiagServices** | `com.qti.diagservices` | Qualcomm diagnostics |
| **QdcmFF** | `com.qti.snapdragon.qdcm_ff` | Display color management |
| **Rftoolkit** | `com.oem.rftoolkit` | RF engineering toolkit |
| **colorservice** | `com.qti.service.colorservice` | Display color service |
| oem_tcma | `cn.oneplus.oemtcma` | OnePlus icon pack / OEM theme |
| OPBreathMode | `com.oneplus.brickmode` | "Brick" breath-mode LED |
| OPDataOptimization | `com.oneplus.dataoptimization` | Data-saver "optimization" |
| OPDeskClock | `com.oneplus.deskclock` | OnePlus Clock app |
| OPFilemanager | `com.oneplus.filemanager` | OnePlus File Manager (FilesGoogle removed above) |
| OPGeoIpTime | `com.oneplus.geoiptime` | Geofence time-zone service |
| OPOnlineConfig | `com.oneplus.config` | Remote config service |
| OPSoundTuner | `com.oneplus.sound.tuner` | Sound tuner/EQ |
| OPWifiApSettings | `com.oneplus.wifiapsettings` | OnePlus Wi-Fi AP settings |
| OnePlusWizard | `com.oneplus.setupwizard` | OnePlus setup wizard (OxygenOS 11 persisted) |
| PhotosOnline | `cn.oneplus.photos` | OnePlus cloud Photos sync |
| workloadclassifier | `com.qualcomm.qti.workloadclassifier` | CPU workload classifier |

### `system_ext` → `/priv-app`

| Package dir | Package id | Note |
|-------------|-----------|------|
| **GoogleFeedback** | `com.google.android.feedback` | "Send feedback" service |
| **OPAccessoryFramework** | `com.oneplus.accessory` | OnePlus accessory framework |
| **OPAod** | `com.oneplus.aod` | Always-On Display |
| **OPAppCategoryProvider** | `net.oneplus.provider.appcategoryprovider` | App categorization |
| **OPAppLocker** | `com.oneplus.applocker` | App Locker (privacy vault) |
| **OPBackup** | `com.oneplus.opbackup` | OnePlus cloud backup |
| **OPDeviceManager** | `net.oneplus.odm` | OnePlus device manager |
| **OPDeviceManagerProvider** | `net.oneplus.odm.provider` | OnePlus device manager provider |
| **OPFaceUnlock** | `com.oneplus.faceunlock` | Face unlock |
| **OpLogkit** | `com.oem.oemlogkit` | Log collection |
| **QuickAccessWallet** | `com.android.systemui.plugin.globalactions.wallet` | Power-menu wallet shortcut |
| **OnePlusGallery** | `com.oneplus.gallery` | Photos gallery app |
| SettingsIntelligence | `com.android.settings.intelligence` | Search in Settings app |
| WallpaperCropper | `com.android.wallpapercropper` | Wallpaper crop tool |
| WfdService | `com.qualcomm.wfd.service` | Wi-Fi Display (Miracast) |
| BackupRestoreRemoteService | `com.oneplus.backuprestore.remoteservice` | OnePlus backup/restore remote |
| GoogleOneTimeInitializer | `com.google.android.onetimeinitializer` | One-time Google init (safe to remove) |
| By_3rd_OPCotaApplication | `com.oneplus.cota` | OnePlus OTA updater — **keep only if you want OTA updates** |
| SoterService | `com.tencent.soter.soterserver` | Tencent Soter (WeChat-style attestation) |
| embms | `com.qualcomm.embms` | Cell broadcast MBMS |

### Preloaded / installed during setup (not in the scanned partitions)

These ship preloaded but live **outside** `system`/`product`/`system_ext` app dirs —
the OnePlus apps in `/system/reserve`, the Google apps installed to `/data/app`
during first-time setup (so they're user apps, not baked into the image). All
are non-essential and removable.

| Package dir | Package id | Note |
|-------------|-----------|------|
| **OnePlus Weather** | `net.oneplus.weather` | Weather app (`/system/reserve/Weather`) |
| **OnePlus Recorder** | `com.oneplus.soundrecorder` | Voice/screen recorder (`/system/reserve/OPSoundRecorder`) |
| **OnePlus Notes** | `com.oneplus.note` | Notes app (`/system/reserve/OPNote`) |
| **OnePlus Community** | `net.oneplus.forums` | Community forum app (`/system/reserve/OPForum`) |
| **OnePlus Switch** | `com.oneplus.backuprestore` | Local data backup/transfer (`/system/reserve/OPBackupRestore`) |
| **OnePlus Store** | `com.oneplus.store` | App store (overseas) (`/system/reserve/By_3rd_OnePlusStoreOverSeas`) |
| **Google One** | `com.google.android.apps.subscriptions.red` | Google One — user-installed during setup |
| **Google News** | `com.google.android.apps.magazines` | Google News — user-installed during setup |
| **Google Wallet** | `com.google.android.apps.walletnfcrel` | Google Wallet — user-installed; separate from the power-menu `QuickAccessWallet` component above |

Remove with `adb shell pm uninstall --user 0 <pkg>` (frees storage). The OnePlus
reserve apps are baked into the image and restore via
`cmd package install-existing`; the Google apps restore from the Play Store.

## Keep — removing these breaks SMS, calls, browsing, or core OS

These look optional or sound like bloat, but are telephony/network/framework
components. Do **not** remove them with the list above.

### SMS / MMS / RCS (messaging)
| Package dir | Partition | Package id |
|-------------|-----------|-----------|
| Messages | product/app | `com.google.android.apps.messaging` — the default SMS app |
| MmsService | system/priv-app | `com.android.mms.service` |
| CarrierServices | product/priv-app | `com.google.android.ims` (IMS/RCS) |
| CarrierDefaultApp | system/app | `com.android.carrierdefaultapp` |
| CarrierConfig | system_ext/priv-app | `com.android.carrierconfig` |
| ims | system_ext/priv-app | `org.codeaurora.ims` |
| imssettings | system_ext/app | `com.qualcomm.qti.ims` |
| uceShimService | system_ext/app | `com.qualcomm.qti.uceShimService` (RCS presence) |
| CellBroadcastLegacyApp | system/priv-app | `com.android.cellbroadcastreceiver` (emergency alerts) |
| SmscPlugger | system/app | `com.oneplus.sms.smscplugger` (SMS carrier) |
| Stk | system/app | `com.android.stk` (SIM toolkit, banking/2FA) |
| SimAppDialog | system/app | `com.android.simappdialog` |
| OPCommunicationData | system/priv-app | `com.oneplus.communication.data` |

### Calls / telephony
| Package dir | Partition | Package id |
|-------------|-----------|-----------|
| TeleService | system/priv-app | `com.android.phone` |
| Telecom | system/priv-app | `com.android.server.telecom` |
| TelephonyProvider | system/priv-app | `com.android.providers.telephony` |
| CallLogBackup | system/priv-app | `com.android.calllogbackup` |
| GoogleDialer | product/priv-app | `com.google.android.dialer` — dialer (or keep OnePlus dialer) |
| CallFeaturesSetting | product/app | `com.qualcomm.qti.callfeaturessetting` |
| ConfURIDialer | system_ext/app | `com.qti.confuridialer` |
| QtiTelephonyService | system_ext/app | `com.qualcomm.qti.telephonyservice` |
| qcrilmsgtunnel | system_ext/priv-app | `com.qualcomm.qcrilmsgtunnel` |
| QAS_DVC_MSP | system_ext/priv-app | `com.qti.ltebc` |
| remoteSimLockAuthentication | system_ext/app | `com.qualcomm.qti.remoteSimlockAuth` |
| remotesimlockservice | system_ext/app | `com.qualcomm.qti.uim` |
| uimremoteclient / uimremoteserver | system_ext/app | SIM remote access |
| imssettings | system_ext/app | IMS |
| BlockedNumberProvider | system/priv-app | call blocking |

### Browsing / networking
| Package dir | Partition | Package id |
|-------------|-----------|-----------|
| WebViewGoogle | product/app | `com.google.android.webview` — required by browsers/links |
| TrichromeLibrary | product/app | `com.google.android.trichromelibrary` — WebView/Chrome shared lib |
| HTMLViewer | system/app | `com.android.htmlviewer` |
| NetworkStackGoogle | system/priv-app | `com.google.android.networkstack` |
| NetworkPermissionConfigGoogle | system/priv-app | permission config |
| CaptivePortalLoginGoogle / PlatformCaptivePortalLogin | system/app | Wi-Fi login portals |
| PacProcessor | system/app | Web proxy |
| VpnDialogs | system/priv-app | VPN |

### Core OS (framework / UI / services) — necessary for a bootable phone
| Package dir | Partition | Package id |
|-------------|-----------|-----------|
| Settings | system_ext/priv-app | `com.android.settings` |
| OPSystemUI | system_ext/priv-app | `com.android.systemui` |
| OPSettingsProvider | system_ext/priv-app | `com.android.providers.settings` |
| OPLauncher2 | system_ext/priv-app | `net.oneplus.launcher` (home screen — replace, don't just delete) |
| SetupWizard | product/priv-app + system_ext | Google setup wizard |
| GmsCore | product/priv-app | `com.google.android.gms` (Play services) |
| GoogleServicesFramework | system_ext/priv-app | `com.google.android.gsf` |
| GooglePackageInstaller | system/priv-app | package installer |
| GoogleExtShared | system/app | Google shared framework |
| oneplus-framework-res | system_ext/priv-app | `com.oneplus` — system framework resources, **do not remove** |
| ContactsProvider | system/priv-app | contacts database (address book) |
| TelephonyProvider | system/priv-app | telephony db |
| MediaProviderLegacy | system/priv-app | media db |
| FusedLocation | system/priv-app | location |
| Bluetooth | system/app | `com.android.bluetooth` (BT stack) |
| LatinImeGoogle | product/app | `com.google.android.inputmethod.latin` — keyboard (needed to type; keep or install a keyboard first) |
| Phonesky (Play Store) | product/priv-app | `com.android.vending` — needed to install/update apps (not for SMS/calls/browsing itself) |
| uimlpaservice | system_ext/app | `com.qualcomm.qti.lpa` (eSIM) |

## Method (reproducible)

```bash
require /usr/sbin/debugfs   # e2fsprogs; raw ext4 reader, no root needed

# list app dirs in a partition image
debugfs -R "ls /app" flash-files/product.img
debugfs -R "ls /priv-app" flash-files/product.img

# dump an APK to read its manifest
debugfs -R "dump /app/Chrome/Chrome.apk /tmp/Chrome.apk" flash-files/product.img

# package id, e.g. with androguard (pip install androguard)
python -c "from androguard.core.apk import APK; print(APK('/tmp/Chrome.apk').get_package())"
```

Partition images (`system`, `product`, `system_ext`) come from splitting the OPS
`super.img` container — see [Parts of the Super Image](super-image-partitions.md).

## Related docs
- [Debloat — Google apps](debloat-google.md) — Google-package bloat only, with disable commands
- [Debloat — OnePlus apps](debloat-oneplus.md) — OnePlus-package bloat only, with disable commands
- [Image Files By Purpose](image-files-by-purpose.md) — what each partition image is for
- [Parts of the Super Image](super-image-partitions.md) — how the dynamic partitions break out
