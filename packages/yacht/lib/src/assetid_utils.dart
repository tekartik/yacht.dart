library;

import 'package:path/path.dart';

/// Normalize a path to posix format.
String normalizePath(String path) {
  // Ugly...
  return posix.normalize(
    posix.joinAll(posix.split(posix.joinAll(windows.split(path)))),
  );
}
