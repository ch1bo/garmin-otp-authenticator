using Toybox.Lang;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Time;

enum {
  ERROR,
  WARN,
  INFO,
  DEBUG
}

function log(level, msg) {
  var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  var levelStr = "";
  switch (level) {
    case ERROR:
      levelStr = "ERROR";
      break;
    case WARN:
      levelStr = "WARN";
      break;
    case INFO:
      levelStr = "INFO";
      break;
    case DEBUG:
      levelStr = "DEBUG";
      break;
  }
  System.println(Lang.format("$1$-$2$-$3$ $4$:$5$:$6$ $7$ $8$",
                 [ date.year
                 , date.month.format("%02d")
                 , date.day.format("%02d")
                 , date.hour.format("%02d")
                 , date.min.format("%02d")
                 , date.sec.format("%02d")
                 , levelStr, msg ]));
}

function logf(level, format, values) {
  return log(level, Lang.format(format, values));
}
