import Toybox.WatchUi;

class MainMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => "Configure" });
    addItem(new MenuItem("New provider", null, :new_provider, null));
    if (!(WatchUi has :ActionMenu)) {
      addItem(new MenuItem("Delete provider", null, :delete_provider, null));
    }
    addItem(new MenuItem("Delete all", null, :delete_all, null));
    addItem(new MenuItem("Export to settings", null, :export_providers, null));
    addItem(new MenuItem("Import from settings", null, :import_providers, null));
    // TODO: configure pin here
  }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    switch (item.getId()) {
    case :new_provider:
      WatchUi.pushView(new ProviderMenu("New provider", null), new ProviderMenuDelegate(null), WatchUi.SLIDE_LEFT);
      return;
    case :delete_provider:
      var deleteMenu = new WatchUi.Menu2({ :title => "Delete" });
      for (var i = 0; i < _providers.size(); i++) {
        deleteMenu.addItem(new WatchUi.MenuItem(_providers[i].name_, null, _providers[i], null));
      }
      WatchUi.pushView(deleteMenu, new DeleteMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :delete_all:
      WatchUi.pushView(new WatchUi.Confirmation("Really delete?"),
                       new DeleteAllConfirmationDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :export_providers:
      var count = exportToSettings();
      if (!Device.showToast("Exported " + count + " entries")) {
        item.setSubLabel("Exported " + count + " entries");
      }
      return;
    case :import_providers:
      if (canImportFromSettings()) {
        askImportConfirmation();
      } else {
        if (!Device.showToast("Nothing to import")) {
          item.setSubLabel("Nothing to import");
        }
      }
      return;
    }
  }

  function onBack() {
    WatchUi.switchToView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_RIGHT);
  }
}

class DeleteMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    log(DEBUG, "DeleteMenuDelegate onSelect");
    var provider = item.getId() as Provider;
    logf(DEBUG, "Deleting $1$", [provider.name_]);
    WatchUi.pushView(new WatchUi.Confirmation("Delete " + provider.name_ + "?"),
                      new DeleteConfirmationDelegate(provider),
                      WatchUi.SLIDE_LEFT);
  }
}

class DeleteAllConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() {
    WatchUi.ConfirmationDelegate.initialize();
  }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        _providers = [];
        _currentIndex = 0;
        saveProviders();
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}
