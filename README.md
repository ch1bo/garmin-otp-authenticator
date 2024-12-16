# garmin-otp-authenticator

[Garmin ConnectIQ Store Link](https://apps.garmin.com/en-US/apps/c601e351-9fa8-4303-aead-441251559064)

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

Keys are stored encrypted using Garmin's application storage on the Device. In the past the application storage was not retained when updating a widget to a newer version, but this seems to be no issue anymore (since CIQ 3.0.0?). However, entered provider data along with secret keys are quite naturally wiped when removing or reinstalling the App.

To provide an easy way of data migration, e.g. when switching Garmin devices an export/import mechanism was added!

### Export keys

To export keys from the encrypted application storage, open the menu in the "OTP Authenticator" widget (touch or menu button). When selecting "Export", all provider entries are copied into application properties **until next start**. You can access the exported data in the Settings of the widget.

**IMPORTANT** Secrets are available unencrypted in settings after exporting until the next start. Make sure you backup the exported data in a secure way, e.g. in your password manager with encrypted storage. Also, there is a chance that this leaks the payload to the garmin servers!

### Import keys

Using the same approach as above, previously exported key data can be imported again via the Widget settings. On every widget start, all available data is loaded and cleared from the corresponding settings entry.

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
the following list of devices should be considered as they are in a way special
or representative:

- `fenix847mm`: flagship model, ciq 5.0, amoled, touch, buttons, round
- `fenix8solar51mm`: bigger, mip screen, solar bezel
- `fenix6spro`: ciq 3.4, smaller, mip, buttons only, fenix 6 most popular (> 40%)
- `vivoactive4`: ciq 3.3, touch, less buttons, popular (> 13%)
- `vivoactive3`: ciq 3.1, no glance, different navigation
- `venu3`: touch, less buttons, different action view
- `venusq2m`: rectangular shape
- `instinct2`: semi-octagon shape with subscreen, black-white screen

To run all of these in sequence, use `./run-in-docker.sh ./test-all.sh`. To
advance from one device to the next in the manual test, the widget must stop
gracefully, e.g. using the back button.

[Full list](https://developer.garmin.com/connect-iq/compatible-devices/) of
devices and their capabilities

## Future work / feature ideas

* Rotating code colors for counter-based OTP.
* Sort entries on demand
* Encrypt on export with AES
* Other device support - on demand
* Choosable interval and code length for Time-based
* Bigger font for Steam-Guard codes (requires custom font)
* Optional master password/PIN
* Other UI/UX improvements - feedback welcome!

## License

The source code for garmin-otp-authenticator is released under the [Mozilla Public License Version 2.0](http://www.mozilla.org/MPL/).

<a href="https://www.flaticon.com/free-icons/lock" title="lock icons">Lock icons created by Roundicons - Flaticon</a>

<a href="https://www.flaticon.com/free-icons/time" title="time icons">Time icons created by Freepik - Flaticon</a>

<a href="https://www.flaticon.com/free-icons/counter" title="counter icons">Counter icons created by Freepik - Flaticon</a>

<a href="https://www.flaticon.com/free-icons/brands-and-logotypes" title="brands and logotypes icons">Brands and logotypes icons created by pictogramer - Flaticon</a>
