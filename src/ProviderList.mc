import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  var menuHeader_ as BitmapResource;

  function initialize(providers as Lang.Array<Provider>) {
    // var h = System.getDeviceSettings().screenHeight;
    // logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    // // TODO: Heights and locations taken from fenix847 simulator.json -> move to a layout per device?
    var title = new WatchUi.Text({
      :text => "OTP Providers",
      :font => Graphics.FONT_AUX2, // TODO: CIQ 4.2.2
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => 109,
      :justification => Graphics.TEXT_JUSTIFY_VCENTER
    });
    WatchUi.CustomMenu.initialize(116, Graphics.COLOR_BLACK, {
      :title => title,
      :titleItemHeight => 131,
      :theme => WatchUi.MENU_THEME_PURPLE
    });
    // WatchUi.Menu2.initialize({
    //   :title => "All Providers",
    //   :theme => WatchUi.MENU_THEME_PURPLE
    // });

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      // addItem(new WatchUi.IconMenuItem(p.name_, p.code_, i, new ProviderIconDrawable(p), {}));
      addItem(new CustomEntry(i, p));
    }

    // var editButton = new WatchUi.Button({
    //   :text => "Edit",
    //   :height => 50,
    //   :width => 300,
    //   :locX => WatchUi.LAYOUT_HALIGN_CENTER,
    //   :locY => 10,
    //   :background => Graphics.COLOR_DK_BLUE,
    //   :stateDefault => Graphics.COLOR_DK_GRAY,
    //   :stateHighlighted => Graphics.COLOR_WHITE
    // });
    // addItem(new WatchUi.CustomMenuItem(:edit, { :drawable => editButton }));

    menuHeader_ = WatchUi.loadResource(Rez.Drawables.MenuHeaderBackground);
  }

  function onHide() {
    log(DEBUG, "custom onHide");
  }

  function onLayout(dc) {
    logf(DEBUG, "custom onLayout $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // WatchUi.Menu2.onLayout(dc);
  }

  function onShow() {
    log(DEBUG, "custom onShow");
    WatchUi.Menu2.onShow();
  }

  function onUpdate(dc) {
    logf(DEBUG, "custom onUpdate $1$ $2$", [dc.getWidth(), dc.getHeight()]);
  }

  function drawTitle(dc) {
    logf(DEBUG, "custom drawTitle $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // TODO: this is bigger than the default menu2
    // TODO: make bitmap as part of title drawable
    dc.drawBitmap(0, 0, menuHeader_);
    WatchUi.CustomMenu.drawTitle(dc);
  }

  function drawForeground(dc) {
    logf(DEBUG, "custom drawForeground $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // NOTE: Using a layout to specify input hints to be able to use the
    // 'personality' builtin style
    // XXX: ordering of items in layout matters
    var menuHint = Rez.Layouts.ProviderList(dc)[0];
    menuHint.draw(dc);
  }
}

class ProviderIconDrawable extends WatchUi.Drawable {
  var provider_;

  function initialize(provider) {
    WatchUi.Drawable.initialize({});
    provider_ = provider;
  }

  function draw(dc) {
    logf(DEBUG, "ProviderIconDrawable draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    var iconSize = 40;

    switch (provider_) {
    case instanceof SteamGuardProvider:
    case instanceof TimeBasedProvider:
      var totp = provider_ as TimeBasedProvider;
      // Colored arc depending on countdown
      var delta = totp.next_ - Time.now().value();
      var iconColor = CountdownColor.getCountdownColor(delta);
      dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
      dc.setPenWidth(iconSize / 2);
      // XXX: improve this
      dc.drawArc(
        iconSize / 2,
        iconSize / 2,
        // I don't understand how the radius parameter works
        // Apparently a quarter width works to get a complete circle
        iconSize / 4,
        Graphics.ARC_COUNTER_CLOCKWISE,
        90, ((delta * 360) / totp.interval_) + 90
      );
      break;
    case instanceof CounterBasedProvider:
      // TODO: draw a counter symbol
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
        break;
      default:
        WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
