import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    // // TODO: Heights and locations taken from fenix847 simulator.json -> make this a device-specific drawable
    WatchUi.CustomMenu.initialize(h / 4, Graphics.COLOR_BLACK, {
      :title => new TitleDrawable("OTP Providers"),
      :titleItemHeight => (h * 0.3).toNumber(),
      :theme => WatchUi.MENU_THEME_BLUE
    });

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      addItem(new ProviderMenuItem(i, p));
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
  }

  function onHide() {
    log(DEBUG, "ProviderList onHide");
    WatchUi.CustomMenu.onHide();
  }

  function onLayout(dc) {
    logf(DEBUG, "ProviderList onLayout $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    WatchUi.CustomMenu.onLayout(dc);
  }

  function onShow() {
    log(DEBUG, "ProviderList onShow");
    WatchUi.CustomMenu.onShow();
  }

  function drawTitle(dc) {
    logf(DEBUG, "ProviderList drawTitle $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    WatchUi.CustomMenu.drawTitle(dc);
  }

  function drawForeground(dc) {
    logf(DEBUG, "ProviderList drawForeground $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // NOTE: Using a layout to specify input hints to be able to use the
    // 'personality' builtin style
    // XXX: ordering of items in layout matters
    var menuHint = Rez.Layouts.ProviderList(dc)[0];
    menuHint.draw(dc);
  }
}

class TitleDrawable extends WatchUi.Drawable {
  var titleText_ as Drawable;
  var menuHeader_ as Bitmap;

  function initialize(title as String) {
    WatchUi.Drawable.initialize({});
    titleText_ = new WatchUi.Text({
      :text => title,
      :font => Graphics.FONT_AUX2, // TODO: CIQ 4.2.2
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :justification => Graphics.TEXT_JUSTIFY_VCENTER
    });
    menuHeader_ = new WatchUi.Bitmap({ :rezId =>Rez.Drawables.MenuHeaderBackground });
  }

  function draw(dc) {
    logf(DEBUG, "Fenix8Title draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    menuHeader_.draw(dc);
    titleText_.draw(dc);
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
