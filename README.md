# garmin-otp-authenticator

[Garmin ConnectIQ Store Link][connectiq-store]

Garmin ConnectIQ Widget for One-Time Passwords as Second Factor Authentication (2FA) similar to Google Authenticator. Multiple OTP formats are supported.

Keys can be entered directly and are stored encrypted using Garmin's application storage. This way, the secret keys will never leave your device and can provide a truly secure second factor!

Less secure, but more convenient: key data can be also added, exported and imported via widget settings.

## Features

* Timed One-Time Passwords (TOTP) using SHA1 with 30 sec interval and 6 digit codes (not configurable)
* Counter-based One-Time Passwords (HOTP) using SHA1 with 6 digit codes (not configurable)
* Steam Guard compatible One-Time Passwords
* Standalone, offline and no companion Smartphone App required
* Direct input of names and keys
* Encrypted storage of keys, can be backed up and restored
* Add provider entries via settings
* Import/export entries via settings
* Uses but not required native cryptography (since Connect IQ 3.0.0)

## Getting started

1. Add widget to your device and access it
2. Tap the screen or use the select button to start
3. Pick a name for your first provider entry
4. Enter the secret key of your first provider key
  - This step highly depends on the service use like to authenticate
  - Usually you will be provided a QR Code
  - If available, use "manual entry" to get access to the actual key
  - Or you can use a QR Code Reader APP to decode the QR Code
  - The secret key looks like: "32QXEKZZXO2ZVJJDWU2KTTDUZ52Q4USN"
5. Pick the provider type, most likely its a time-based (TOTP) code

### Text input controls

* Use up/down or swipe to switch characters
* Tap or the select button picks a character
* Swipe back or back button deletes a character
* Long press the screen or the select button first asks confirmation, and if long pressed again, continues

## Backup / Restore

Keys are stored encrypted using Garmin's application storage on the Device. In the past the application storage was not retained when updating a widget to a newer version, but this seems to be no isuse anymore (since CIQ 3.0.0?). However, entered provider data along with secret keys are quite naturally wiped when removing or reinstalling the App.

To provide an easy way of data migration, e.g. when switching Garmin devices an export/import mechanism was added!

### Export keys

To export keys from the encrypted application storage, open the menu in the "OTP Authenticator" widget (touch or menu button). When selecting "Export", all provider entries are copied into application properties **until next start**. You can access the exported data in the Settings of the widget.

**IMPORTANT** Secrets are available unencrypted in settings after exporting until the next start. Make sure you backup the exported data in a secure way, e.g. in your password manager with encrypted storage. Also, there is a chance that this leaks the payload to the garmin servers!

### Import keys

Using the same approach as above, previously exported key data can be imported again via the Widget settings. On every widget start, all available data is loaded and cleared from the corresponding settings entry.

## Planned features

* Encrypt on export with AES
* Performance improvements and (:glance) optimizations
* Other device support - on demand
* Edit name, key and code type
* Choosable interval and code length for Time-based
* Better touch UX on text input - scroll momentum
* Bigger font for Steam-Guard codes (requires custom font)
* Other UI/UX improvements - feedback welcome!

## Steam guard

This app does support the steam guard authentication code scheme. However,
access onto the secret key is usually not provided by the setup.

If you have a rooted Android phone, you can read the secret key out of the
installed and configured steam Android App.

The secret is located in a file at path
`/data/data/com.valvesoftware.android.steam.community/files/Steamguard*` and can
be read using `adb` or a local shell and `su` (thus the rooted phone
requirement).


## License

The source code for garmin-otp-authenticator is released under the [Mozilla Public License Version 2.0](http://www.mozilla.org/MPL/).

Launcher icon made by [Roundicons][roundicons] from [www.flaticon.com][flaticon]
is licensed by [Creative Commns BY 3.0][cc30by].

[connectiq-store]: https://apps.garmin.com/en-US/apps/c601e351-9fa8-4303-aead-441251559064
[roundicons]: https://www.flaticon.com/authors/roundicons
[flaticon]: https://www.flaticon.com
[cc30by]: http://creativecommons.org/licenses/by/3.0/


