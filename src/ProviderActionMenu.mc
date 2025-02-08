import Toybox.WatchUi;

function showProviderActionMenu(provider as Provider) {
  log(DEBUG, "showProviderActionMenu");
  var menu = new WatchUi.ActionMenu({});
  if (provider instanceof CounterBasedProvider) {
    menu.addItem(new ActionMenuItem({ :label => "Next" }, :next));
  }
  menu.addItem(new ActionMenuItem({ :label => "Edit" }, :edit));
  menu.addItem(new ActionMenuItem({ :label => "Delete" }, :delete));
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
    case :next:
      if (provider_ instanceof CounterBasedProvider) {
        provider_.next();
        WatchUi.requestUpdate();
      }
      return;
    case :edit:
      var index = _providers.indexOf(provider_);
      if (index >= 0) {
        var menu = new ProviderMenu("Edit provider", index);
        WatchUi.pushView(menu, new ProviderMenuDelegate(menu, index), WatchUi.SLIDE_LEFT);
      }
      return;
    case :delete:
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
