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
* Uses native cryptography when available (since Connect IQ 3.0.0)

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

* Rotating code colors for counter-based OTP.
* Edit name, key and code type and lexical sorted entries
* Encrypt on export with AES
* Other device support - on demand
* Choosable interval and code length for Time-based
* Better touch UX on text input - scroll momentum
* Bigger font for Steam-Guard codes (requires custom font)
* Optional master password/PIN
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

## Development

Due to very old libraries used in the Garmin SDK, notably in the simulator,
modern Linux distributions and especially NixOS is hard to support. Thus, the
current "best" practice is to use an Ubuntu docker image like [this
one](https://github.com/kalemena/docker-connectiq), onto which I only needed to
add `make` to get a docker image for my workflow:

```
docker build . -t connectiq
./run-in-docker.sh
developer@c2efd41df61f$ make start
```

The docker container uses the SDKs and Device files from the `.Garmin/` working
directory. To check for new and download SDK packages, launch `sdkmanager` from
within the docker container. Also, for some tasks the Garmin IDE is helpful,
available in the `eclipse` of the docker container.

While a default device is defined in `Makefile`, one can select the device to
run tests for or start the simulator on with `DEVICE=<device name in manifest>`.

### Testing

The codebase contains tests about the logic which can be run with `make test`,
while the interface needs to be tested manually with the simulator using `make
start`.

Testing with all supported devices on every change is obviously infeasible, but
the following list of devices should be considered as they are in way or the
other special or representative:

- `vivoactive3`: the device of the creator of this widget (still), touch screen
- `vivoactive_hr`: an old api level 2.4.0 device with square screen, touch screen
- `fenix5`: good representative for api level 3.1.0, buttons only
- `fenix6`: good representative for api level 3.4.0, buttons only
- `fenix7`: good representative for api level 4.2.0, touch screen
- `venu2`: amoled (full color) higher resolution screen
- `instinct2`: semi-octagon shape with subscreen, black-white screen

[Full list](https://developer.garmin.com/connect-iq/compatible-devices/) of
devices and their capabilities

## License

The source code for garmin-otp-authenticator is released under the [Mozilla Public License Version 2.0](http://www.mozilla.org/MPL/).

Launcher icon made by [Roundicons][roundicons] from [www.flaticon.com][flaticon]
is licensed by [Creative Commns BY 3.0][cc30by].

[connectiq-store]: https://apps.garmin.com/en-US/apps/c601e351-9fa8-4303-aead-441251559064
[roundicons]: https://www.flaticon.com/authors/roundicons
[flaticon]: https://www.flaticon.com
[cc30by]: http://creativecommons.org/licenses/by/3.0/


