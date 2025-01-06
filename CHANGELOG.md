# Changelog

## 2.2.1 - UNRELEASED

- Fix out of memory errors of glance view by only deserializing current provider.
- Don't split keys in provider menu splitting when using legacy text input.
- Detect duplicates by provider name on import.
- Add support for Forerunner 265 and 265s.

## 2.2.0 - 2024-12-28

- Support OTP keys with 32+ character length (e.g. Amazon which uses 64):
  - The new / edit provider menu now adds "Key" menu items when hitting maximum text input length (31 characters).
  - All key entry fields are combined into the full key on confirming with "Done".
  - Allow spaces in key text pickers for a way to exit the native text picker.
- Add support for Enduro, Enduro 3 and Forerunner 165 (+ Music) devices.

## 2.1.0 - 2024-12-19

- Fix out of memory errors on Forerunner 245 / 935 and Instinct 2 devices by disabling provider list icons.
- Add support for Instinct Crossover.

## 2.0.0 - 2024-12-17

- New UX flow including full list of providers with otp codes.
  - Native text picker, menus and action menus where available.
  - Edit OTP providers via action menu.
  - New setting to keep using the legacy text input method.
- **BREAKING** Dropped support of old devices (CIQ < 3.0.0):
  - Vivoactive HR
  - Forerunner 735xt
- Add support for Venu Sq 2.

## 1.8.0 - 2024-09-05

 - Add support for Fenix 8 (all variants).
 - Add support for Forerunner 965.
 - Add support for Vivoactive 5.
 - Add support for Marq Gen 2.
 - Fix background of glance view to be transparent.

## 1.7.0 - 2023-09-24

 - Add support for Venu 3 and 3s.
 - Add support for Fenix 7 Pro, 7s Pro and 7x Pro.
 - Add support for Forerunner 255, 255s and music variants.
 - Add support for Approach S70 42mm and 47mm.
 - Add support for Epix Pro (Gen 2) 42, 47 and 51mm.
 - Increase code font size on old and small devices.
 - Fix confirm prompt overlapping on text input menu.
 - Gradually typed implementation to resolve compiler warnings.
 - Use 80x80 base icon image. Device builds will scale down.

## 1.6.0 - 2023-07-21

 - Added » into the alphabet to confirm TextInput.
 - Add support for Forerunner 955
 - Add support for Instinct 2, 2x and 2s.
 - Use the subscreen to show progress when available.

## 1.5.0 - 2022-05-14

 - Add support for Descent Mk2 and Epix 2 watches.

## 1.4.0 - 2022-03-06

 - Add support for Venu 2 Plus Fenix 7, 7S and 7X watches.
 - Add settings to configure refresh rate of main view and glance view.

## 1.3.0 - 2022-01-06

 - Add support for Forerunner 55, drawing the code with a smaller font.
 - Add support for Forerunner 735xt, 745 and MARQ devices.

## 1.2.0 - 2021-11-20

 - Add support for Venu 2 devices.
 - Add support for Forerunner 935 devices.
 - Visualize remaining time as circular/rectangular progress bar (@shinji).
 - Add a glance view (@shinji).
 - Quick switch providers with Up/Down buttons (@The-Compiler).
 - Save providers when leaving widget (@JuanPotato).
 - Only draw entered, to be confirmed text green in TextInput.
 - Paint counter-based codes always green and mention "MENU" button.

## 1.1.0 - 2020-10-31

 - Move OTP provider selection into submenu with unlimited number of entries on
    newer devices (CIQ > 3.0.0). Old devices still only show 16 entries max, but
    not in conflict with app menu entries.
 - Ask for confirmation before deleting all entries.
 - Add support for Forerunner 645 devices.

## 1.0.5 - 2020-10-03

 - Filter whitespace and add padding as necessary on settings import. This
    fixes usage of Amazon OTP secrets.

## 1.0.4 - 2020-09-22

 - Support base32 padding ('=') characters when decoding keys.

## 1.0.3 - 2020-09-19

 - Add support for fenix5 series, fenix6 serias, fr945 and venu.
 - Slightly space out lines in main view to accomodate denser displays.
 - Do not load full app in glance view.

## 1.0.2 - 2020-07-06

 - Add support for vivoactive 4(s)

## 1.0.1 - 2020-05-12

 - Improve instructions and menu titles.
 - Fix the 'Counter based' provider type.

## 1.0.0 - 2020-05-10

 - Use native cryptography when available (CIQ > 3.0.0)
 - Layout fixes for to support round devices.
 - Support long press on physical ENTER key in text input.

## 0.2.0 - 2018-10-23

 - Add support for Steam Guard and Counter-based one time password types.
 - Add import/export via settings.
 - Add addition of new keys via settings.

## 0.1.0 - 2018-01-06

 - Initial release
