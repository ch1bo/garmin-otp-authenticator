using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;

var _providers = [];
var _currentIndex = 0;
var _error = "";

function currentProvider() {
  if (_currentIndex >= 0 && _currentIndex < _providers.size()) {
    return _providers[_currentIndex];
  }
  return null;
}

function loadProviders() {
  var ps = Application.Storage.getValue("providers");
  if (ps) {
    for (var i = 0; i < ps.size(); i++) {
      try {
        _providers.add(providerFromDict(ps[i]));
      } catch (exception) {
        _error = exception.getErrorMessage();
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
  System.println("exported");
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
      System.println("added: " + type + "/" + addName);
      Application.Properties.setValue("addName", "");
      Application.Properties.setValue("addKey", "");
    } catch (exception instanceof InvalidValueException) {
      System.println("error adding: " + type + "/" + addName);
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
        System.println("imported: " + ps[i].name_);
      }
    }
    Application.Properties.setValue("exportData", "");
  }
}

class App extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    loadProviders();
    importFromSettings();
    saveProviders();
  }

  function onStop(state) {
    saveProviders();
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }

  function onSettingsChanged() {
    System.println("settings changed");
    importFromSettings();
    saveProviders();
    WatchUi.requestUpdate();
  }
}
