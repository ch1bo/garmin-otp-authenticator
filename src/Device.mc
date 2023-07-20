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

}
