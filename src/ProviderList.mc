import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    var title = new WatchUi.Text({
      :text => "OTP Providers",
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER
    });
    WatchUi.CustomMenu.initialize(h / 4, Graphics.COLOR_BLACK, {
      :title => title,
      :theme => WatchUi.MENU_THEME_PURPLE
    });

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      self.addItem(new WatchUi.CustomMenuItem(i, { :drawable => new CustomEntryDrawable(p) }));
    }
  }

  function drawForeground(dc) {
    // NOTE: Using a layout to specify input hints to be able to use the
    // 'personality' builtin style
    // XXX: ordering of items in layout matters
    var menuHint = Rez.Layouts.ProviderList(dc)[0];
    menuHint.draw(dc);
  }
}

class ProviderListDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
