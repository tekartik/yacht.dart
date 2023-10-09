///
/// Development helpers to generate warning in code
///
library;

bool _devPrintEnabled = true;

@Deprecated('Dev only')
set devPrintEnabled(bool enabled) => _devPrintEnabled = enabled;

@Deprecated('Dev only')
void devPrint(Object object) {
  if (_devPrintEnabled) {
    print(object);
  }
}

@Deprecated('Dev only')
int? devWarning;

void _devError([String msg = '']) {
  // one day remove the print however sometimes the error thrown is hidden
  try {
    throw UnsupportedError(msg);
  } catch (e, st) {
    if (_devPrintEnabled) {
      print('# ERROR $msg');
      print(st);
    }
    rethrow;
  }
}

@Deprecated('Dev only')
void devError([String msg = '']) => _devError(msg);
