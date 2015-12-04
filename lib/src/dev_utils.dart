library yacht.src.dev_utils;

///
/// Development helpers to generate warning in code
///

bool _devPrintEnabled = true;

@deprecated
set devPrintEnabled(bool enabled) => _devPrintEnabled = enabled;

@deprecated
void devPrint(Object object) {
  if (_devPrintEnabled) {
    print(object);
  }
}

@deprecated
int devWarning;

_devError([String msg = null]) {
  // one day remove the print however sometimes the error thrown is hidden
  try {
    throw new UnsupportedError(msg);
  } catch (e, st) {
    if (_devPrintEnabled) {
      print("# ERROR $msg");
      print(st);
    }
    throw e;
  }
}

@deprecated
devError([String msg = null]) => _devError(msg);
