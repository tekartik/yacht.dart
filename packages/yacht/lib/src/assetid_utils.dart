library;

import 'package:path/path.dart';

// convert to posix
String normalizePath(String path) {
  // Ugly...
  return posix.normalize(
    posix.joinAll(posix.split(posix.joinAll(windows.split(path)))),
  );
}
