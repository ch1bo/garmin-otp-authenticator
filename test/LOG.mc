using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function log_test(logger) {
  log(DEBUG, "debug");
  log(INFO, "info");
  log(WARN, "warn");
  log(ERROR, "error");
  return true;
}
