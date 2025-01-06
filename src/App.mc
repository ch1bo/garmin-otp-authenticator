import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

var _providers as Array<Provider> = [];
var _currentIndex = 0;

(:glance)
function currentProvider() as Provider? {
  if (_currentIndex >= 0 && _currentIndex < _providers.size()) {
    return _providers[_currentIndex];
  }
  return null;
}

(:glance)
function loadCurrentProvider() as Provider? {
  var ci = Application.Storage.getValue("currentIndex");
  if (ci != null) {
    _currentIndex = ci;
  }
  var ps = Application.Storage.getValue("providers") as Array<ProviderDict>;
  if (ps != null) {
    switch (ps) {
      case instanceof Array:
        if (_currentIndex >= 0 && _currentIndex < ps.size()) {
          return providerFromDict(ps[_currentIndex]);
        }
        break;
    }
  }
  return null;
}

function loadProviders() {
  var ci = Application.Storage.getValue("currentIndex");
  if (ci != null) {
    _currentIndex = ci;
  }
  var ps = Application.Storage.getValue("providers") as Array<ProviderDict>;
  if (ps != null) {
    switch (ps) {
      case instanceof Array:
        _providers = [];
        var maxEntries = Application.Properties.getValue("maxEntries");
        for (var i = 0; i < ps.size() && i < maxEntries; i++) {
          try {
            _providers.add(providerFromDict(ps[i]));
          } catch (exception) {
            var msg = exception.getErrorMessage();
            log(ERROR, msg);
            // NOTE(SN): We can't really report these errors and not loading them
            // here, will result in the entry being dropped from storage! As this
            // does result in data loss, we opt for the lesser evil and rethrow the
            // exception with some information. That way, should this ever happen
            // (highly unlikely in the field), we get the error via ERA and can
            // assist the user.
            throw new Lang.InvalidValueException("loadProviders() failed: " + msg);
          }
        }
        break;
      default:
        logf(ERROR, "loadProviders loaded $1", [ps]);
        throw new Lang.InvalidValueException("loadProviders() loaded not an array");
    }
  }
}

function saveProviders() {
  var ps = new [_providers.size()];
  for (var i = 0; i < _providers.size(); i++) {
    ps[i] = providerToDict(_providers[i]);
  }
  Application.Storage.setValue("providers", ps);
  Application.Storage.setValue("currentIndex", _currentIndex);
}

function exportToSettings() as Number {
  // XXX: encrypt with AES?
  Application.Properties.setValue("exportData", serializeProviders(_providers));
  log(INFO, "exported");
  return _providers.size();
}

// Returns true if we could add/import entries using importFromSettings
function canImportFromSettings() as Boolean {
  var addType = Application.Properties.getValue("addType");
  var addName = Application.Properties.getValue("addName");
  var addKey = Application.Properties.getValue("addKey");
  var exportData = Application.Properties.getValue("exportData");
  var canAdd =
    addType != null &&
    addName != null && !addName.equals("") &&
    addKey != null && !addKey.equals("");
  var canImport = exportData != null && !exportData.equals("");
  return canAdd || canImport;
}

function importFromSettings() {
  var addType = Application.Properties.getValue("addType");
  var addName = Application.Properties.getValue("addName");
  var addKey = Application.Properties.getValue("addKey");
  if (addType != null &&
      addName != null && !addName.equals("") &&
      addKey != null && !addKey.equals("")) {
    var type = PROVIDERS[addType];
    try {
      var p = providerFromDict({
        "type" => type,
        "name" => addName,
        "key" => addKey
      });
      p.update();
      _providers.add(p);
      Application.Properties.setValue("addName", "");
      Application.Properties.setValue("addKey", "");
      Device.infoToast("Added " + addName);
    } catch (exception) {
      var msg = exception.getErrorMessage();
      log(ERROR, "error adding from settings (" + type + "/" + addName + "): " + msg);
      Application.Properties.setValue("addKey", "error: " + msg);
      Device.warnToast("Import failed, details in addKey");
    }
  }

  // XXX: decrypt with AES?
  var exportData = Application.Properties.getValue("exportData");
  if (exportData != null && !exportData.equals("")) {
    try {
      var ps = parseProviders(exportData);
      for (var i = 0; i < ps.size(); i++) {
        var index = findProviderByName(_providers, ps[i].name_);
        if (index >= 0 && index < _providers.size()) {
          _providers[index] = ps[i];
          log(INFO, "updated: " + ps[i].name_);
        } else {
          _providers.add(ps[i]);
          log(INFO, "added: " + ps[i].name_);
        }
      }
      Application.Properties.setValue("exportData", "");
      Device.infoToast("Imported " + ps.size() + " entries");
    } catch (exception) {
      var msg = exception.getErrorMessage();
      Application.Properties.setValue("exportData", "error: " + msg);
      Device.warnToast("Import failed, details in exportData");
      log(ERROR, "error importing from settings: " + msg);
    }
  }
}

function findProviderByName(providers as Array<Provider>, name as String) as Number {
  for (var i = 0; i < providers.size(); i++) {
    if (providers[i].name_.equals(name)) {
      return i;
    }
  }
  return -1;
}

(:glance)
class App extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    log(DEBUG, "App onStart");
  }

  function onStop(state) {
    log(DEBUG, "App onStop");
  }

  function getInitialView() {
    log(DEBUG, "App getInitialView");
    loadProviders();
    // TODO: optional pin entry
    if (WatchUi has :GlanceView) {
      return [new ProviderList(), new ProviderListDelegate()];
    } else {
      return [new MainView(), new MainViewDelegate()];
    }
  }

  function getGlanceView() {
    log(DEBUG, "App getGlanceView");
    var p = loadCurrentProvider();
    return [new WidgetGlanceView(p)];
  }

  function onSettingsChanged() {
    log(DEBUG, "App onSettingsChanged");
    if (canImportFromSettings()) {
      askImportConfirmation();
    }
  }
}

function askImportConfirmation() {
  WatchUi.pushView(new WatchUi.Confirmation("Import from settings?"),
                   new ImportConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
}

class ImportConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() {
    WatchUi.ConfirmationDelegate.initialize();
  }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        importFromSettings();
        saveProviders();
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
    return true;
  }
}
