import Toybox.WatchUi;

// TODO: als use this as edit menu

class NewItemMenu extends WatchUi.Menu2 {
  function initialize(title, name, key, type) {
    Menu2.initialize({:title => "New item"});
    addItem(new MenuItem("Name", "", :name, {}));
    addItem(new MenuItem("Key", "", :key, {}));
    addItem(new MenuItem("Type", "Time based", :type, {}));
    addItem(new MenuItem("Done", "", :done, {}));
  }
}

class NewItemMenuDelegate extends WatchUi.Menu2InputDelegate {
  var doneItem_ = null;

  function initialize() {
    Menu2InputDelegate.initialize();
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
        WatchUi.pushView(new WatchUi.TextPicker(""), new NameInputDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :key:
        WatchUi.pushView(new WatchUi.TextPicker(""), new KeyInputDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :type:
        WatchUi.pushView(new TypeMenu(), new TypeMenuDelegate(item), WatchUi.SLIDE_RIGHT);
        break;
      case :done:
        doneItem_ = item;
        if (_enteredName == null) {
          // Only available > CIQ 3.4
          if (WatchUi has :showToast) {
            WatchUi.showToast("Name required", {});
          } else {
            doneItem_.setSubLabel("Name required");
            new Timer.Timer().start(method(:resetDoneItem), 2000, false);
          }
          return;
        }
        if (_enteredKey == null) {
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
        case :time:
          provider = new TimeBasedProvider(_enteredName, _enteredKey, 30);
          break;
        case :counter:
          provider = new CounterBasedProvider(_enteredName, _enteredKey, 0);
          break;
        case :steam:
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
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}

// Name, key and type input view stack

var _enteredName = null;

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

var _enteredKey = null;

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
    addItem(new WatchUi.MenuItem("Time based", null, :time, null));
    addItem(new WatchUi.MenuItem("Counter based", null, :counter, null));
    addItem(new WatchUi.MenuItem("Steam guard", null, :steam, null));
  }
}

var _enteredType = :time;

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
