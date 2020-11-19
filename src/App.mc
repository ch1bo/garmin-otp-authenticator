using Toybox.Application;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

var _providers = [];
var _currentIndex = 0;

(:glance)
function currentProvider() {
  if (_currentIndex >= 0 && _currentIndex < _providers.size()) {
    return _providers[_currentIndex];
  }
  return null;
}

function selectProvider(index) {
  logf(DEBUG, "selectProvider $1$ / $2$", [index, _providers.size()]);
  if (index >= 0 && index < _providers.size()) {
    _currentIndex = index;
    saveProviders();
  }
}

function deleteCurrentProvider() {
  var cur = currentProvider();
  if (cur != null) {
    _providers.remove(cur);
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
    }
    saveProviders();
  }
}

function deleteAllProviders() {
  _providers = [];
  _currentIndex = 0;
  saveProviders();
}

function saveProviders() {
  var ps = new [_providers.size()];
  for (var i = 0; i < _providers.size(); i++) {
    ps[i] = providerToDict(_providers[i]);
  }
  Application.Storage.setValue("providers", ps);
  Application.Storage.setValue("currentIndex", _currentIndex);
}

(:glance)
function loadProviders() {
  var ps = Application.Storage.getValue("providers");
  if (ps) {
    for (var i = 0; i < ps.size(); i++) {
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
  }
  var ci = Application.Storage.getValue("currentIndex");
  if (ci != null) {
    _currentIndex = ci;
  }
}

function exportToSettings() {
  // TODO(SN): encrypt with AES
  Application.Properties.setValue("exportData", serializeProviders(_providers));
  log(INFO, "exported");
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
      log(INFO, "added: " + type + "/" + addName);
      Application.Properties.setValue("addName", "");
      Application.Properties.setValue("addKey", "");
    } catch (exception) {
      var msg = exception.getErrorMessage();
      log(ERROR, "error adding from settings (" + type + "/" + addName + "): " + msg);
      Application.Properties.setValue("addKey", "error: " + msg);
    }
  }

  // TODO(SN): decrypt with AES
  var exportData = Application.Properties.getValue("exportData");
  if (exportData != null && !exportData.equals("")) {
    try {
      var ps = parseProviders(exportData);
      for (var i = 0; i < ps.size(); i++) {
        if(_providers.indexOf(ps[i]) < 0) {
          _providers.add(ps[i]);
          log(INFO, "imported: " + ps[i].name_);
        }
      }
      Application.Properties.setValue("exportData", "");
    } catch (exception) {
      var msg = exception.getErrorMessage();
      log(ERROR, "error importing from settings: " + msg);
      Application.Properties.setValue("exportData", "error: " + msg);
    }
  }
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
    // saveProviders();
  }

  function getInitialView() {
    loadProviders();
    importFromSettings();
    saveProviders();
    return [new MainView(), new MainViewDelegate()];
  }

  function getGlanceView() {
    log(DEBUG, "App GlanceView");
    loadProviders();
    return [ new WidgetGlanceView() ];
  }

  function onSettingsChanged() {
    log(DEBUG, "onSettingsChanged");
    importFromSettings();
    saveProviders();
    WatchUi.requestUpdate();
  }
}
