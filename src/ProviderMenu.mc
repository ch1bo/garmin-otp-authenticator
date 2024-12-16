import Toybox.WatchUi;
import Toybox.Lang;

// Menu to create or edit a provider entry
class ProviderMenu extends WatchUi.Menu2 {
  function initialize(title as String, editIndex as Number or Null) {
    Menu2.initialize({:title => title});
    var name = "";
    var key = "";
    var type = "Time based";
    if (editIndex != null && editIndex < _providers.size()) {
      var provider = _providers[editIndex];
      name = provider.name_;
      key = provider.key_;
      type = provider.getTypeString();
    }
    addItem(new MenuItem("Name", name, :name, {}));
    addItem(new MenuItem("Key", key, :key, {}));
    addItem(new MenuItem("Type", type, :type, {}));
    addItem(new MenuItem("Done", "", :done, {}));
  }
}

class ProviderMenuDelegate extends WatchUi.Menu2InputDelegate {
  var doneItem_ = null;
  var editIndex_ = null;

  function initialize(editIndex as Number or Null) {
    Menu2InputDelegate.initialize();
    if (editIndex != null && editIndex < _providers.size()) {
      editIndex_ = editIndex;
      var provider = _providers[editIndex];
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
        // TODO: Opt-in to old txt input
        if (WatchUi has :TextPicker) {
          WatchUi.pushView(new WatchUi.TextPicker(_enteredName), new NameTextPickerDelegate(item), WatchUi.SLIDE_LEFT);
        } else {
          var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM, _enteredName);
          WatchUi.pushView(view, new NameTextInputDelegate(view, item), WatchUi.SLIDE_LEFT);
        }
        break;
      case :key:
        // TODO: Opt-in to old txt input
        if (WatchUi has :TextPicker) {
          WatchUi.pushView(new WatchUi.TextPicker(_enteredKey), new KeyInputDelegate(item), WatchUi.SLIDE_LEFT);
        } else {
          var view = new TextInput.TextInputView("Enter Key", Alphabet.BASE32, _enteredKey);
          WatchUi.pushView(view, new KeyTextInputDelegate(view, item), WatchUi.SLIDE_LEFT);
        }
        break;
      case :type:
        WatchUi.pushView(new TypeMenu(), new TypeMenuDelegate(item), WatchUi.SLIDE_LEFT);
        break;
      case :done:
        doneItem_ = item;
        if (_enteredName.equals("")) {
          var shown = Device.showToast("Name required");
          if (!shown) {
            doneItem_.setSubLabel("Name required");
            new Timer.Timer().start(method(:resetDoneItem), 2000, false);
          }
          return;
        }
        if (_enteredKey.equals("")) {
          var shown = Device.showToast("Key required");
          if (!shown) {
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
          if (editIndex_ != null) {
            _providers[editIndex_] = provider;
            _currentIndex = editIndex_;
          } else {
            _providers.add(provider);
            _currentIndex = _providers.size() - 1;
          }
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

class NameTextPickerDelegate extends WatchUi.TextPickerDelegate {
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

class NameTextInputDelegate extends TextInput.TextInputDelegate {
  var item_;

  function initialize(view, item) {
    TextInput.TextInputDelegate.initialize(view);
    item_ = item;
  }

  function onTextEntered(text) {
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

class KeyTextInputDelegate extends TextInput.TextInputDelegate {
  var item_;

  function initialize(view, item) {
    TextInput.TextInputDelegate.initialize(view);
    item_ = item;
  }

  function onTextEntered(text) {
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
