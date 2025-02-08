import Toybox.WatchUi;
import Toybox.Lang;

// Maximum number of characters allowed in the native text picker. This is
// relevant when entering keys which are longer than this.
const MAX_TEXT_PICKER_LENGTH as Number = 31;

var _enteredName as String = "";
var _enteredKey as Array<String> = [""];
// XXX: Should use an enum with string mapping
var _enteredType as String or Null = "Time based";

// Menu to create or edit a provider entry
class ProviderMenu extends WatchUi.Menu2 {
  var typeItem_;
  var doneItem_;

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
    // Never split on first load or when using legacy input
    if (key.equals("") || useLegacyTextInput(Application.Properties)) {
      addItem(new MenuItem("Key", "", 0, {}));
    } else {
      // Create menu items for each key part
      var keyParts = splitIntoChunks(key, MAX_TEXT_PICKER_LENGTH);
      for (var i = 0; i < keyParts.size(); i++) {
        var part = keyParts[i];
        var start = i * MAX_TEXT_PICKER_LENGTH + 1;
        var end = start + part.length() - 1;
        addItem(new MenuItem("Key   " + start.toString() + "..." + end.toString(), ellipsizeMiddle(part, 12), i, {}));
      }
    }
    typeItem_ = new MenuItem("Type", type, :type, {});
    addItem(typeItem_);
    doneItem_ = new MenuItem("Done", "", :done, {});
    addItem(doneItem_);
  }

  function deleteItem_(item as WatchUi.MenuItem) {
    var idx = findItemById(item.getId());
    if (idx > -1) {
      deleteItem(idx);
    }
  }

  // Ensure a menu item for given key index is in the menu. This only adds one
  // item if the key index is not found. By repeatedly calling this, one can
  // ensure there are enough entries.
  function ensureKeyItem(keyIndex as Number) {
    // Key menu items use key index as identifier
    if (self.findItemById(keyIndex) == -1) {
      // Delete type and done items
      deleteItem_(typeItem_);
      deleteItem_(doneItem_);
      // Add an empty key item
      var start = keyIndex * MAX_TEXT_PICKER_LENGTH + 1;
      addItem(new MenuItem("Key   " + start.toString() + "...", "", keyIndex, {}));
      _enteredKey.add("");
      // Re-add type and done items
      addItem(typeItem_);
      addItem(doneItem_);
    }
  }
}

class ProviderMenuDelegate extends WatchUi.Menu2InputDelegate {
  var menu_;
  var doneItem_ = null;
  var editIndex_ = null;

  function initialize(menu as ProviderMenu, editIndex as Number or Null) {
    Menu2InputDelegate.initialize();
    menu_ = menu;
    if (editIndex != null && editIndex < _providers.size()) {
      editIndex_ = editIndex;
      var provider = _providers[editIndex];
      _enteredName = provider.name_;
      // Split key into parts for native text picker
      if (useLegacyTextInput(Application.Properties)) {
        _enteredKey = [provider.key_];
      } else {
        _enteredKey = splitIntoChunks(provider.key_, MAX_TEXT_PICKER_LENGTH);
      }
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
        if (useLegacyTextInput(Application.Properties)) {
          var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM, _enteredName);
          WatchUi.pushView(view, new NameTextInputDelegate(view, item), WatchUi.SLIDE_LEFT);
        } else {
          WatchUi.pushView(new WatchUi.TextPicker(_enteredName), new NameTextPickerDelegate(item), WatchUi.SLIDE_LEFT);
        }
        break;
      case instanceof Number:
        // NOTE: Key menu items use key index as identifier.
        if (useLegacyTextInput(Application.Properties)) {
          var view = new TextInput.TextInputView("Enter Key", Alphabet.BASE32, _enteredKey[0]);
          WatchUi.pushView(view, new KeyTextInputDelegate(view, item), WatchUi.SLIDE_LEFT);
        } else {
          var keyIndex = item.getId() as Number;
          WatchUi.pushView(new WatchUi.TextPicker(_enteredKey[keyIndex]), new KeyTextPickerDelegate(menu_, item, keyIndex), WatchUi.SLIDE_LEFT);
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
        var combinedKey = "";
        for (var i = 0; i < _enteredKey.size(); i++) {
          combinedKey = combinedKey + _enteredKey[i];
        }
        logf(DEBUG, "Combined key: $1$ $1$", [combinedKey.length(), combinedKey]);
        if (combinedKey.equals("")) {
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
          provider = new TimeBasedProvider(_enteredName, combinedKey, 30);
          break;
        case "Counter based":
          provider = new CounterBasedProvider(_enteredName, combinedKey, 0);
          break;
        case "Steam guard":
          provider = new SteamGuardProvider(_enteredName, combinedKey, 30);
          break;
        }
        // TODO: handle error?
        if (provider != null) {
          _enteredName = "";
          _enteredKey = [""];
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
                     WatchUi.SLIDE_RIGHT);
  }
}

class AbortConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() {
    WatchUi.ConfirmationDelegate.initialize();
  }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        _enteredName = "";
        _enteredKey = [""];
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}

// Name, key and type input view stack

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

class KeyTextPickerDelegate extends WatchUi.TextPickerDelegate {
  var menu_;
  var item_;
  var keyIndex_;

  function initialize(menu as ProviderMenu, item as WatchUi.MenuItem, keyIndex as Number) {
    WatchUi.TextPickerDelegate.initialize();
    menu_ = menu;
    item_ = item;
    keyIndex_ = keyIndex;
    if (keyIndex >= _enteredKey.size()) {
      logf(ERROR, "KeyTextPickerDelegate: keyIndex $1$ out of range $2$", [keyIndex, _enteredKey.size()]);
    }
  }

  function onTextEntered(text, changed) {
    var upper = text.toUpper();
    var chars = upper.toCharArray();
    // Remove spaces - allow entering spaces to exit text picker
    chars.removeAll(' ');
    // Validate input
    for (var i = 0; i < chars.size(); i++) {
      var c = chars[i];
      if (Alphabet.BASE32.indexOf(c) == -1) {
        var msg = "Illegal character: " + c;
        var shown = Device.showToast(msg);
        if (!shown) {
          item_.setSubLabel(msg);
        }
        return false;
      }
    }
    var validated = StringUtil.charArrayToString(chars);
    _enteredKey[keyIndex_] = validated;
    logf(DEBUG, "Length $1$: $2$", [validated.length(), validated]);

    var start = keyIndex_ * MAX_TEXT_PICKER_LENGTH + 1;
    var end = start + validated.length() - 1;
    item_.setLabel("Key   " + start.toString() + "..." + end.toString());
    item_.setSubLabel(ellipsizeMiddle(validated, 12));

    if (validated.length() >= MAX_TEXT_PICKER_LENGTH) {
      logf(DEBUG, "Max length used add/use menu item for key index $1$", [keyIndex_ + 1]);
      menu_.ensureKeyItem(keyIndex_ + 1);
    }

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
    _enteredKey[0] = text;
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

// Helpers

// Ellipsize a string in the middle, such that its overall not longer than given length.
function ellipsizeMiddle(text as String, length as Number) as String {
  if (text.length() > length) {
    return text.substring(0, length/2) + "..." + text.substring(-length/2, null);
  }
  return text;
}

// Split a string into chunks of given length.
function splitIntoChunks(str as String, chunkLength as Number) as Array<String> {
  var chunks = [];
  var i = 0;
  while (i < str.length()) {
    var end = i + chunkLength;
    if (end > str.length()) {
      end = str.length();
    }
    chunks.add(str.substring(i, end));
    i = end;
  }
  return chunks;
}

// Determine whether to use legacy text input using settings and feature availability.
function useLegacyTextInput(props) as Boolean {
  var legacySetting = props.getValue("legacyTextInput");
  return !(WatchUi has :TextPicker) || (legacySetting != null && legacySetting);
}
