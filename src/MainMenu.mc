import Toybox.WatchUi;

class MainMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => "OTP Authenticator" });
    addItem(new MenuItem("New provider", null, :new_provider, null));
    addItem(new MenuItem("Delete all", null, :delete_all, null));
    addItem(new MenuItem("Export to settings", null, :export_providers, null));
    // TODO: Add "Import from settings" screen with instructions
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
    case :delete_all:
      WatchUi.pushView(new WatchUi.Confirmation("Really delete?"),
                       new DeleteAllConfirmationDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :export_providers:
      exportToSettings();
      return;
    }
  }

  function onBack() {
    WatchUi.switchToView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_RIGHT);
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
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}
