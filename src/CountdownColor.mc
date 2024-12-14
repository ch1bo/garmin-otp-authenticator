import Toybox.Graphics;

module CountdownColor {

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

}
