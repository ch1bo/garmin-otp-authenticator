import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.Menu2 {
  var providers_ as Lang.Array<Provider>;
  var timer_;

  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    WatchUi.Menu2.initialize({
      :title => "OTP Providers",
      :theme => WatchUi.MENU_THEME_BLUE, // XXX: CIQ >= 4.1.8
      :dividerType => DIVIDER_TYPE_ICON // Ignored on CIQ < 5.0.1
    });

    providers_ = providers;
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      addItem(new WatchUi.IconMenuItem(p.name_, p.code_, i, new ProviderIcon(p), {}));
    }

    addItem(new WatchUi.MenuItem("Configure", null, :edit, {}));
  }

  function onHide() {
    log(DEBUG, "ProviderList onHide");
    WatchUi.Menu2.onHide();
    timer_.stop();
    timer_ = null;
  }

  function onShow() {
    log(DEBUG, "ProviderList onShow");
    WatchUi.Menu2.onShow();
    timer_ = new Timer.Timer();
    timer_.start(method(:onTimer), 5000, true);
  }

  function onTimer() as Void {
    for (var i = 0; i < providers_.size(); i++) {
      var p = providers_[i];
      p.update();
      var delta = (p as TimeBasedProvider).next_ - Time.now().value();
      getItem(i).setSubLabel(p.code_ + " - " + delta.toString());
    }
    WatchUi.requestUpdate();
  }
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

  const ICON_TIME_BASED_GREEN = loadProviderIcon($.Rez.Drawables.TimeBasedGreen);
  const ICON_TIME_BASED_ORANGE = loadProviderIcon($.Rez.Drawables.TimeBasedOrange);
  const ICON_TIME_BASED_RED = loadProviderIcon($.Rez.Drawables.TimeBasedRed);
  const ICON_COUNTER_BASED = loadProviderIcon($.Rez.Drawables.CounterBased);
  const ICON_COUNTER_STEAM = loadProviderIcon($.Rez.Drawables.SteamGuard);

  function initialize(provider as Provider) {
    WatchUi.Drawable.initialize({});
    provider_ = provider;
  }

  function draw(dc) {
    logf(DEBUG, "ProviderIcon draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // TODO: move icon selection into Provider class?
    switch (provider_) {
      case instanceof SteamGuardProvider:
        // TODO: colored steam icons
        ICON_COUNTER_STEAM.draw(dc);
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

class ProviderListDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    switch (item.getId()) {
      case :edit:
        log(INFO, "Edit button pressed");
        WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
        break;
      default:
        _currentIndex = item.getId();
        logf(DEBUG, "Setting current index $1$", [_currentIndex]);
        saveProviders();
        WatchUi.pushView(new MainView(), new MainViewDelegate(), WatchUi.SLIDE_LEFT);
        break;
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
