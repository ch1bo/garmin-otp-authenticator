import Toybox.WatchUi;

function showProviderActionMenu(provider as Provider) {
  log(DEBUG, "showProviderActionMenu");
  var menu = new WatchUi.ActionMenu({});
  menu.addItem(new ActionMenuItem({ :label => "New" }, :new_entry));
  menu.addItem(new ActionMenuItem({ :label => "Delete" }, :delete_entry));
  WatchUi.showActionMenu(menu, new ProviderActionMenuDelegate(provider));
}

class ProviderActionMenuDelegate extends WatchUi.ActionMenuDelegate {
  var provider_;

  function initialize(provider) {
    WatchUi.ActionMenuDelegate.initialize();
    provider_ = provider;
  }

  function onSelect(item) {
    switch (item.getId()) {
    case :new_entry:
      WatchUi.pushView(new NewItemMenu("New item", null, null, :time), new NewItemMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :delete_entry:
      WatchUi.pushView(new WatchUi.Confirmation("Delete " + provider_.name_ + "?"),
                       new DeleteConfirmationDelegate(provider_),
                       WatchUi.SLIDE_LEFT);
      return;
    }
  }
}

class DeleteConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  var provider_;

  function initialize(provider) {
    WatchUi.ConfirmationDelegate.initialize();
    provider_ = provider;
  }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        _providers.remove(provider_);
        _currentIndex = 0;
        saveProviders();
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}