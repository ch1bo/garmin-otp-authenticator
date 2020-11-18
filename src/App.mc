using Toybox.Application;
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

(:glance)
function loadProviders(displayerror) {
  var ps = Application.Storage.getValue("providers");
  if (ps) {
    for (var i = 0; i < ps.size(); i++) {
      try {
        _providers.add(providerFromDict(ps[i]));
      } catch (exception) {
        var msg = exception.getErrorMessage();
        log(ERROR, msg);
        if (displayerror) {
          displayError(msg);
        }
      }
    }
  }
  var ci = Application.Storage.getValue("currentIndex");
  if (ci != null) {
    _currentIndex = ci;
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
    } catch (exception instanceof InvalidValueException) {
      log(ERROR, "error adding: " + type + "/" + addName);
      Application.Properties.setValue("addKey", "error: " + exception.getErrorMessage());
    }
  }

  // TODO(SN): decrypt with AES
  var exportData = Application.Properties.getValue("exportData");
  if (exportData != null && !exportData.equals("")) {
    var ps = parseProviders(exportData);
    for (var i = 0; i < ps.size(); i++) {
      if(_providers.indexOf(ps[i]) < 0) {
        _providers.add(ps[i]);
        log(INFO, "imported: " + ps[i].name_);
      }
    }
    Application.Properties.setValue("exportData", "");
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
    saveProviders();
  }

  function getInitialView() {
    loadProviders(true);
    importFromSettings();
    saveProviders();
    return [new MainView(), new MainViewDelegate()];
  }

  function getGlanceView() {
    log(DEBUG, "App GlanceView");
    loadProviders(false);
    return [ new WidgetGlanceView() ];
  }

  function onSettingsChanged() {
    log(DEBUG, "onSettingsChanged");
    importFromSettings();
    saveProviders();
    WatchUi.requestUpdate();
  }
}
