library yacht.src.assetid_utils;

import 'package:barback/src/asset/asset_id.dart';
export 'package:barback/src/asset/asset_id.dart';
import 'package:path/path.dart';

// convert to posix
String normalizePath(String path) {
  return posix.normalize(posix.joinAll(split(path)));
}

/// generate the target assetId for a given path
AssetId assetIdWithPath(AssetId id, String path) {
  if (path == null) {
    return null;
  }
  path = normalizePath(path);
  String package;

  // resolve other package?
  if (path.startsWith(posix.join("packages", ""))) {
    List<String> parts = posix.split(path);
    // 0 is packages
    if (parts.length > 2) {
      package = parts[1];
    }
    // Beware append "lib" here to only get what is exported
    path = posix.joinAll(parts.sublist(2));
    path = posix.join("lib", path);
  } else {
    // default id
    if (id != null) {
      package = id.package;

      // try relative
      if (!posix.isAbsolute(path)) {
        path = posix.join(posix.dirname(id.path), path);
      }
    }
  }
  return new AssetId(package, path);
}
