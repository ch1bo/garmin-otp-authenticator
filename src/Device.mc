// Anti-corruption layer to make certain features backward compatible or get
// additional information about the device we are running on.

import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

module Device {

(:glance)
function getSubscreen() {
  if (WatchUi has :getSubscreen) {
    return WatchUi.getSubscreen();
  }
  return null;
}

(:glance)
function subscreenIsTopRight(screenWidth) {
  var subscreen = getSubscreen();
  return (
    subscreen != null && subscreen.y == 0 &&
    // Is horizontal position of subscreen >= 90% of remaining screen width?
    subscreen.x >= (screenWidth - subscreen.width) * 0.9
  );
}

enum {
  BLACK_AND_WHITE,
  COLOR,
}

(:isColor)
function getPalette() {
  return COLOR;
}

(:isBlackAndWhite)
function getPalette() {
  return BLACK_AND_WHITE;
}

// Colored OTP code depending on countdown

(:glance, :isColor)
function getCountdownColor(delta) {
  if (delta < 5) {
    return Graphics.COLOR_RED;
  } else if (delta <= 10) {
    return Graphics.COLOR_ORANGE;
  }

  return Graphics.COLOR_GREEN;
}

(:glance, :isBlackAndWhite)
function getCountdownColor(delta) {
  return Graphics.COLOR_WHITE;
}

// Toast or no toast

function showToast(msg) as Lang.Boolean {
  if (WatchUi has :showToast) {
    WatchUi.showToast(msg, {});
    return true;
  }
  return false;
}

function warnToast(msg) as Lang.Boolean {
  log(WARN, msg);
  if (WatchUi has :showToast) {
    var options = {};
    if (Rez.Drawables has :WarningToastIcon) {
      options = { :icon => Rez.Drawables.WarningToastIcon };
    }
    WatchUi.showToast(msg, options);
    return true;
  }
  return false;
}

function infoToast(msg) as Lang.Boolean {
  log(INFO, msg);
  if (WatchUi has :showToast) {
    var options = {};
    if (Rez.Drawables has :InfoToastIcon) {
      options = { :icon => Rez.Drawables.InfoToastIcon };
    }
    WatchUi.showToast(msg, options);
    return true;
  }
  return false;
}

}
