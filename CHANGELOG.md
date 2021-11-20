# Changelog

## 1.2.0 - UNRELEASED

  * Add support for Venu 2 devices.
  * Visualize remaining time as circular/rectangular progress bar (@shinji).
  * Add a glance view (@shinji).
  * Save providers when leaving widget (@JuanPotato).

## 1.1.0 - 2020-10-31

  * Move OTP provider selection into submenu with unlimited number of entries on
    newer devices (CIQ > 3.0.0). Old devices still only show 16 entries max, but
    not in conflict with app menu entries.
  * Ask for confirmation before deleting all entries.
  * Add support for Forerunner 645 devices.

## 1.0.5 - 2020-10-03

  * Filter whitespace and add padding as necessary on settings import. This
    fixes usage of Amazon OTP secrets.

## 1.0.4 - 2020-09-22

  * Support base32 padding ('=') characters when decoding keys.

## 1.0.3 - 2020-09-19

  * Add support for fenix5 series, fenix6 serias, fr945 and venu.
  * Slightly space out lines in main view to accomodate denser displays.
  * Do not load full app in glance view.

## 1.0.2 - 2020-07-06

  * Add support for vivoactive 4(s)

## 1.0.1 - 2020-05-12

  * Improve instructions and menu titles.
  * Fix the 'Counter based' provider type.

## 1.0.0 - 2020-05-10

  * Use native cryptography when available (CIQ > 3.0.0)
  * Layout fixes for to support round devices.
  * Support long press on physical ENTER key in text input.

## 0.2.0 - 2018-10-23

  * Add support for Steam Guard and Counter-based one time password types.
  * Add import/export via settings.
  * Add addition of new keys via settings.

## 0.1.0 - 2018-01-06

  * Initial release
