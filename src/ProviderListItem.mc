import Toybox.WatchUi;

// Use icons by default
(:icons)
function mkProviderListItem(provider, index) {
  log(DEBUG, "mkProviderListItem with icon");
  return new WatchUi.IconMenuItem(provider.name_, provider.code_, index, new ProviderIcon(provider), {});
}

// No icons for low-memory devices
(:noIcons)
function mkProviderListItem(provider, index) {
  log(DEBUG, "mkProviderListItem without icon");
  return new WatchUi.MenuItem(provider.name_, provider.code_, index, {});
}

function loadProviderIcon(resourceId) {
  return new WatchUi.Bitmap({
    :rezId => resourceId,
    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
    :locY => WatchUi.LAYOUT_VALIGN_CENTER
  });
}

class ProviderIcon extends WatchUi.Drawable {
  var provider_ as Provider;

  static var ICON_TIME_BASED_GREEN = null;
  static var ICON_TIME_BASED_ORANGE = null;
  static var ICON_TIME_BASED_RED = null;
  static var ICON_COUNTER_BASED = null;
  static var ICON_STEAM_GUARD = null;

  function initialize(provider as Provider) {
    WatchUi.Drawable.initialize({});
    provider_ = provider;

    // Lazy load icons
    switch (provider_) {
      case instanceof SteamGuardProvider:
        if (ICON_STEAM_GUARD == null) {
          ICON_STEAM_GUARD = loadProviderIcon(Rez.Drawables.SteamGuard);
        }
        break;
      case instanceof TimeBasedProvider:
        if (ICON_TIME_BASED_GREEN == null) {
          ICON_TIME_BASED_GREEN = loadProviderIcon(Rez.Drawables.TimeBasedGreen);
        }
        if (ICON_TIME_BASED_ORANGE == null) {
          ICON_TIME_BASED_ORANGE = loadProviderIcon(Rez.Drawables.TimeBasedOrange);
        }
        if (ICON_TIME_BASED_RED == null) {
          ICON_TIME_BASED_RED = loadProviderIcon(Rez.Drawables.TimeBasedRed);
        }
        break;
      case instanceof CounterBasedProvider:
        if (ICON_COUNTER_BASED == null) {
          ICON_COUNTER_BASED = loadProviderIcon(Rez.Drawables.CounterBased);
        }
        break;
    }
  }

  function draw(dc) {
    logf(DEBUG, "ProviderIcon draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    if (dc has :setAntiAlias) {
      dc.setAntiAlias(true);
    }
    // TODO: move icon selection into Provider class?
    switch (provider_) {
      case instanceof SteamGuardProvider:
        // TODO: colored steam icons
        ICON_STEAM_GUARD.draw(dc);
        break;
      case instanceof TimeBasedProvider:
        var delta = (provider_ as TimeBasedProvider).next_ - Time.now().value();
        if (delta < 5) {
          ICON_TIME_BASED_RED.draw(dc);
        } else if (delta <= 10) {
          ICON_TIME_BASED_ORANGE.draw(dc);
        } else {
          ICON_TIME_BASED_GREEN.draw(dc);
        }
        break;
      case instanceof CounterBasedProvider:
        ICON_COUNTER_BASED.draw(dc);
        break;
    }
  }
}
