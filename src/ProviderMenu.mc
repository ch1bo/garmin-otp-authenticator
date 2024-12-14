import Toybox.WatchUi;
import Toybox.Lang;

// Menu to create or edit a provider entry
class ProviderMenu extends WatchUi.Menu2 {
  function initialize(title as String, provider as Provider or Null) {
    Menu2.initialize({:title => title});
    var name = "";
    if (provider != null) {
      name = provider.name_;
    }
    addItem(new MenuItem("Name", name, :name, {}));
    var key = "";
    if (provider != null) {
      key = provider.key_;
    }
    addItem(new MenuItem("Key", key, :key, {}));
    var type = "Time based";
    if (provider != null) {
      type = provider.getTypeString();
    }
    addItem(new MenuItem("Type", type, :type, {}));
    addItem(new MenuItem("Done", "", :done, {}));
  }
}

class ProviderMenuDelegate extends WatchUi.Menu2InputDelegate {
  var doneItem_ = null;

  function initialize(provider as Provider or Null) {
    Menu2InputDelegate.initialize();
    if (provider != null) {
      _enteredName = provider.name_;
      _enteredKey = provider.key_;
    }
  }

  function resetDoneItem() as Void {
    if (doneItem_ != null) {
      doneItem_.setSubLabel("");
      WatchUi.requestUpdate();
    }
  }

  function onSelect(item) {
    switch (item.getId()) {
      case :name:
        // REVIEW: use callbacks instead of passed items?
        WatchUi.pushView(new WatchUi.TextPicker(_enteredName), new NameInputDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :key:
        WatchUi.pushView(new WatchUi.TextPicker(_enteredKey), new KeyInputDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :type:
        WatchUi.pushView(new TypeMenu(), new TypeMenuDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :done:
        doneItem_ = item;
        if (_enteredName.equals("")) {
          // Only available > CIQ 3.4
          if (WatchUi has :showToast) {
            WatchUi.showToast("Name required", {});
          } else {
            doneItem_.setSubLabel("Name required");
            new Timer.Timer().start(method(:resetDoneItem), 2000, false);
          }
          return;
        }
        if (_enteredKey.equals("")) {
          // Only available > CIQ 3.4
          if (WatchUi has :showToast) {
            WatchUi.showToast("Key required", {});
          } else {
            doneItem_.setSubLabel("Key required");
            new Timer.Timer().start(method(:resetDoneItem), 2000, false);
          }
          return;
        }
        // NOTE(SN) When creating providers here, we rely on the fact, that any
        // input provided here (as it uses the Alphabet.BASE32) can be converted to
        // bytes without errors, i.e. base32ToBytes(_enteredKey) will not throw.
        // This is possible, because base32ToBytes also accepts empty strings or
        // strings only consisting of padding.
        var provider = null;
        switch (_enteredType) {
        case "Time based":
          provider = new TimeBasedProvider(_enteredName, _enteredKey, 30);
          break;
        case "Counter based":
          provider = new CounterBasedProvider(_enteredName, _enteredKey, 0);
          break;
        case "Steam guard":
          provider = new SteamGuardProvider(_enteredName, _enteredKey, 30);
          break;
        }
        // TODO: handle error?
        if (provider != null) {
          _providers.add(provider);
          _currentIndex = _providers.size() - 1;
          saveProviders();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
    }
  }

  function onBack() {
    WatchUi.pushView(new WatchUi.Confirmation("Abort?"),
                     new AbortConfirmationDelegate(),
                     WatchUi.SLIDE_LEFT);
  }
}

class AbortConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() {
    WatchUi.ConfirmationDelegate.initialize();
  }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}

// Name, key and type input view stack

var _enteredName = "";

class NameInputDelegate extends WatchUi.TextPickerDelegate {
  var item_;

  function initialize(item) {
    WatchUi.TextPickerDelegate.initialize();
    item_ = item;
  }

  function onTextEntered(text, changed) {
    _enteredName = text;
    item_.setSubLabel(text);
    WatchUi.requestUpdate();
    return true;
  }
}

var _enteredKey = "";

class KeyInputDelegate extends WatchUi.TextPickerDelegate {
  var item_;

  function initialize(item) {
    WatchUi.TextPickerDelegate.initialize();
    item_ = item;
  }

  function onTextEntered(text, changed) {
    // FIXME: validate input
    // TODO: convert to all caps
    _enteredKey = text;
    item_.setSubLabel(text);
    WatchUi.requestUpdate();
    return true;
  }
}

// REVIEW: use resource?
class TypeMenu extends WatchUi.Menu2 {
  function initialize() {
    WatchUi.Menu2.initialize({ :title => "Type" });
    addItem(new WatchUi.MenuItem("Time based", null, "Time based", null));
    addItem(new WatchUi.MenuItem("Counter based", null, "Counter based", null));
    addItem(new WatchUi.MenuItem("Steam guard", null, "Steam guard", null));
  }
}

var _enteredType = "Time based";

class TypeMenuDelegate extends WatchUi.Menu2InputDelegate {
  var item_;

  function initialize(item) {
    WatchUi.Menu2InputDelegate.initialize();
    item_ = item;
  }

  function onSelect(item) {
    _enteredType = item.getId();
    item_.setSubLabel(item.getLabel());
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
