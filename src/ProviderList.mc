import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  var menuHeader_ as BitmapResource;

  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    // TODO: Heights and locations taken from fenix847 simulator.json -> move to a layout per device?
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

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      self.addItem(new WatchUi.CustomMenuItem(i, { :drawable => new CustomEntryDrawable(p) }));
    }

    var editButton = new WatchUi.Button({
      :text => "Edit",
      :height => 50,
      :width => 300,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => 10,
      :background => Graphics.COLOR_DK_BLUE,
      :stateDefault => Graphics.COLOR_DK_GRAY,
      :stateHighlighted => Graphics.COLOR_WHITE
    });
    self.addItem(new WatchUi.CustomMenuItem(:edit, { :drawable => editButton }));

    menuHeader_ = WatchUi.loadResource(Rez.Drawables.MenuHeaderBackground);
  }

  function drawTitle(dc) {
    // TODO: this is bigger than the default menu2
    // TODO: make bitmap as part of title drawable
    dc.drawBitmap(0, 0, menuHeader_);
    WatchUi.CustomMenu.drawTitle(dc);
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
