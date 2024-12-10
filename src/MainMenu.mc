import Toybox.WatchUi;

class MainMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => "OTP Authenticator" });
    addItem(new MenuItem("New entry", null, :new_entry, null));
    addItem(new MenuItem("Delete entry", null, :delete_entry, null));
    addItem(new MenuItem("Delete all entries", null, :delete_all, null));
    addItem(new MenuItem("Export", "to settings", :export_providers, null));
    addItem(new MenuItem("Import", "from settings", :import_providers, null));
  }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    switch (item.getId()) {
    case :new_entry:
      WatchUi.pushView(new NewItemMenu("New item", null, null, :time), new NewItemMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :delete_entry:
      // TODO: modernize!?
      var deleteMenu = new Menu.MenuView({ :title => "Delete" });
      for (var i = 0; i < _providers.size(); i++) {
        deleteMenu.addMenuItem(new Menu.MenuItem(_providers[i].name_, null, _providers[i], null));
      }
      Menu.switchTo(deleteMenu, new DeleteMenuDelegate(), WatchUi.SLIDE_RIGHT);
      return;
    case :delete_all:
      WatchUi.pushView(new WatchUi.Confirmation("Really delete?"),
                       new DeleteAllConfirmationDelegate(), WatchUi.SLIDE_RIGHT);
      return;
    case :export_providers:
      exportToSettings();
      return;
    case :import_providers:
      importFromSettings();
      saveProviders();
      return;
    }
  }

  function onBack() {
    // FIXME: update provider list
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

class DeleteMenuDelegate extends Menu.MenuDelegate {
  function initialize() { Menu.MenuDelegate.initialize(); }

  function onMenuItem(identifier) {
    var provider = currentProvider();
    if (provider != null && provider == identifier) {
      _currentIndex = 0;
    }
    _providers.remove(identifier);
    saveProviders();
  }
}

class DeleteAllConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() { WatchUi.ConfirmationDelegate.initialize(); }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        _providers = [];
        _currentIndex = 0;
        saveProviders();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}
