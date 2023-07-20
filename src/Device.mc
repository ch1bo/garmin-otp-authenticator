// Anti-corruption layer to make certain features backward compatible or get
// additional information about the device we are running on.

using Toybox.WatchUi;

module Device {

(:glance)
function getSubscreen() {
  if (WatchUi has :getSubscreen) {
    return WatchUi.getSubscreen();
  }
  return null;
}

}


// TODO: Make this a class with static fields like System.ScreenShape
(:isColor)
const DISPLAY_IS_BLACK_AND_WHITE = false;

(:isBlackAndWhite)
const DISPLAY_IS_BLACK_AND_WHITE = true;
