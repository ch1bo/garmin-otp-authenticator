// Classes to provide a compatibility layer with a Menu2-like API also on
// ConnectIQ 2.x, but with the size limitation of 16 items, no support for
// sublabels etc. and the "old" callback API in the delegates.

using Toybox.WatchUi;

module Menu {

(:connectiq2)
function switchTo(menu, delegate, transition) {
  // On CIQ 2.x native menus can't be switchViewTo'ed
  WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  WatchUi.pushView(menu, delegate, transition);
}

(:connectiq3)
function switchTo(menu, delegate, transition) {
  WatchUi.switchToView(menu, delegate, transition);
}

(:connectiq2)
class MenuView extends WatchUi.Menu {
  private var nItems;

  function initialize(options) {
    WatchUi.Menu.initialize();
    if (options != null) {
      var title = options.get(:title);
      if (title != null) {
        self.setTitle(title);
      }
      // :focus is ignored
    }
    self.nItems = 0;
  }

  function addItem(item) {
    self.nItems++;
    if (self.nItems > WatchUi.Menu.MAX_SIZE) {
      logf(WARN, "Menu item overflow ($1$ > $2$), truncating items", [self.nItems, WatchUi.Menu.MAX_SIZE]);
    } else {
      WatchUi.Menu.addItem(item.getLabel(), item.getId());
    }
  }
}

(:connectiq3)
class MenuView extends WatchUi.Menu2 {
  function initialize(options) {
    WatchUi.Menu2.initialize(options);
  }
}

(:connectiq2)
// Polyfilled menu item which does ignore sublabel and options
class MenuItem {
  private var label, identifier;

  function initialize(label, sublabel, identifier, options) {
    self.label = label;
    self.identifier = identifier;
  }

  function getId() {
    return self.identifier;
  }

  function getLabel() {
    return self.label;
  }
}

(:connectiq3)
class MenuItem extends WatchUi.MenuItem {
  function initialize(label, sublabel, identifier, options) {
    WatchUi.MenuItem.initialize(label, sublabel, identifier, options);
  }
}

(:connectiq2)
class MenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    WatchUi.MenuInputDelegate.initialize();
  }

  function onMenuItem(id) {
    // Keep the "old" onMenuItem interface as we can't easily resolve id -> item
    // on ConnectIQ 2.x
  }
}

(:connectiq3)
class MenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  // Never wrap
  function onWrap(key) {
    return false;
  }

  function onSelect(item) {
    if (self.onMenuItem(item.getId()) != true) {
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
  }

  function onMenuItem(identifier) {
    // Provide the "old" onMenuItem interface
  }
}

}
