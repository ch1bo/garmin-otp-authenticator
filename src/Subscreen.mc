using Toybox.WatchUi;

module Subscreen {

(:connectiq3,:glance)
function getSubscreen() {
    return WatchUi.getSubscreen();
}

(:connectiq2)
function getSubscreen() {
    return null;
}

}
