# garmin-otp-authenticator

Garmin ConnectIQ Widget for One-Time Passwords as Second Factor Authentication
(2FA) similar to Google Authenticator. Multiple OTP formats are supported.

Keys can be entered directly and are stored encrypted using Garmin's application
storage. This way, the secret keys will never leave your device and can provide
a truly secure second factor!

Less secure, but more convenient: key data can be also added, exported and
imported via widget settings.

[Garmin ConnectIQ Store Link][connectiq-store]

## Features

* Timed One-Time Passwords (TOTP) with 30 sec interval and 6 digit codes (not configurable)
* Counter-based One-Time Passwords (HOTP) with 6 digit codes (not configurable)
* Steam Guard compatible One-Time Passwords
* Standalone, offline and no companion Smartphone App required
* Direct input of a name and base32 key
* Encrypted storage of keys, can be backed up and restored
* Add provider entries via settings
* Import/export entries via settings
* Uses but not required native cryptography (since Connect IQ 3.0.0)

## Planned features

* Encrypt on export with AES
* Performance improvements and (:glance) optimizations
* Other device support - on demand
* Edit name, key and code type
* Choosable interval and code length for Time-based
* Better touch UX on text input - scroll momentum
* Other UI/UX improvements - feedback welcome!

## Backup / Restore

Keys are stored encrypted using Garmin's application storage on the Device. The
keys will stay in this form on the device after de-/re-installing the App
manually or via Connect IQ Store. Unfortunately, the application storage may not
be retained between different versions of the same app!

To overcome this, an import/export mechanism was added to the app settings.

### Export keys

To export keys from the encrypted application storage, open the menu in the "OTP
Authenticator" widget (currently by touching the screen). When selecting
"Export", all provider entries are copied into application properties ***until
next start**. You can access the exported data in the Settings of the widget.

**IMPORTANT** Secrets are available unencrypted in settings after exporting
until the next start. Make sure you backup the exported data in a secure way,
e.g. in your password manager with encrypted storage.

### Import keys

Using the same approach as above, previously exported key data can be imported
again via the Widget settings. On every widget start, all available data is
loaded and cleared from the corresponding settings entry.

## License

The source code for garmin-otp-authenticator is released under the [Mozilla
Public License Version 2.0](http://www.mozilla.org/MPL/).

Launcher icon made by [Roundicons][roundicons] from [www.flaticon.com][flaticon]
is licensed by [Creative Commns BY 3.0][cc30by].

[connectiq-store]: https://apps.garmin.com/en-US/apps/c601e351-9fa8-4303-aead-441251559064
[roundicons]: https://www.flaticon.com/authors/roundicons
[flaticon]: https://www.flaticon.com
[cc30by]: http://creativecommons.org/licenses/by/3.0/


