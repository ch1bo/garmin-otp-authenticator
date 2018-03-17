# garmin-otp-authenticator

Garmin ConnectIQ App for Timed One-Time Passwords (TOTP) Second Factor Authentication (2FA) similar to Google Authenticator. Keys can be entered directly and are stored encrypted using Garmin's application storage. This way, the secret keys will never leave your device and can provide a truly secure second factor!

[Garmin ConnectIQ Store Link][connectiq-store]

## Features

* Timed One-Time Passwords (TOTP) with 30 sec interval and 6 digit codes (not configurable)
* Standalone, offline and no companion Smartphone App required
* Direct input of a name and base32 key
* Encrypted storage of keys, can be backed up and restored

## Planned features

* Edit name, key and code type
* Choosable interval and code length for Time-based
* Better touch UX on text input - scroll momentum
* Other UI/UX improvements - feedback welcome!
* Other device support - low priority / on demand

## Backup / Restore

Keys are stored encrypted using Garmin's application storage on the Device. The keys will stay in this form on the device after de-/re-installing the App manually or via Connect IQ Store. To explicitly backup configured codes, attach the Garmin device to your PC in mass storage mode to access Apps and Data using a File Browser.

Connect IQ Apps and their associated data files are named by a hash and thus one needs to find out the hash of the App, e.g. by modifcation date = install date, optionally re-installing the App (data is kept). For example, version `0.1.0-1` of this authenticor app was installed as `GARMIN/APPS/69E5AEE4.prg` on my device.

Either the whole `GARMIN/APPS/DATA/` directory or the corresponding `.DAT` and `.IDX` can be backed up and restored by just copying them from/to the device. For example, version `0.1.0-1` corresponded to `69E5AEE4`, thus `GARMIN/APPS/DATA/69E5AEE4.DAT` and `GARMIN/APPS/DATA/69E5AEE4.IDX` are to be backed up.

These instructions will be updated should a future version or app update required any action!

## License

The source code for garmin-otp-authenticator is released under the [Mozilla Public License Version 2.0](http://www.mozilla.org/MPL/).

Launcher icon made by [Roundicons][roundicons] from [www.flaticon.com][flaticon] is licensed by [Creative Commns BY 3.0][cc30by].

[connectiq-store]: https://apps.garmin.com/en-US/apps/c601e351-9fa8-4303-aead-441251559064
[roundicons]: https://www.flaticon.com/authors/roundicons
[flaticon]: https://www.flaticon.com
[cc30by]: http://creativecommons.org/licenses/by/3.0/


