library yacht.src.transformer_memory;

import 'package:yacht/src/assetid_utils.dart';
import 'transformer.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

class MemoryAssetId implements AssetId {
  @override
  final String package;

  @override
  final String path;

  MemoryAssetId(this.package, this.path);
  @override

  /// Returns a new [AssetId] with the same [package] and [path] as this one
  /// but with file extension [newExtension].
  AssetId changeExtension(String newExtension) =>
      new MemoryAssetId(package, p.withoutExtension(path) + newExtension);

  @override
  int get hashCode => path?.hashCode ?? 0;

  @override
  bool operator ==(o) {
    return (o is MemoryAssetId) && ((o.package == package) && (o.path == path));
  }

  @override
  String toString() {
    if (package != null) {
      return "package:$package/$path";
    }
    return path;
  }
}

/// generate the target assetId for a given path
AssetId assetIdWithPath(AssetId id, String path) {
  if (path == null) {
    return null;
  }
  path = normalizePath(path);

  bool normalized = false;

  String firstPart = posix.split(path)[0];
  if (firstPart == '.' || firstPart == '..') {
    if (id != null) {
      path = posix.normalize(join(posix.dirname(id.path), path));
    }
    normalized = true;
  }
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
      if ((!normalized) && (!posix.isAbsolute(path))) {
        String dirname = posix.dirname(id.path);
        // Don't join .
        if (dirname != ".") {
          path = posix.join(dirname, path);
        }
      }
    }
  }
  return new MemoryAssetId(package, path);
}

class StringAsset {
  MemoryAssetId id;
  String content;
  StringAsset(this.id, this.content);

  @override
  toString() => '$id:$content';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(o) {
    if (o is StringAsset) {
      return o.id == id && o.content == content;
    }
    return false;
  }
}

class StringAssets extends MapBase<AssetId, StringAsset> {
  Map<AssetId, StringAsset> assets = {};

  @override
  StringAsset remove(Object id) => assets.remove(id);

  @override
  Iterable<AssetId> get keys => assets.keys;

  @override
  void clear() {
    assets.clear();
  }

  StringAsset operator [](Object id) => assets[id];
  operator []=(AssetId id, StringAsset asset) => assets[id] = asset;
}

StringAsset stringAsset(AssetId id, String content) =>
    new StringAsset(id as MemoryAssetId, content);

class StringAssetTransform implements AssetTransform {
  @override
  final AssetId primaryId;

  StringAssetTransform(this.primaryId);

  // implements
  AssetId newAssetId(AssetId assetId, String path) {
    return assetIdWithPath(assetId, path);
  }
}

class StringConsumableTransform extends StringAssetTransform
    implements ConsumableTransform {
  bool isConsumed;
  TransformLogger get logger => null;
  StringConsumableTransform(AssetId primaryId) : super(primaryId);

  @override
  void consumePrimary() {
    isConsumed = true;
  }
}

class StringIsPrimaryTransform extends StringAssetTransform
    implements IsPrimaryTransform {
  StringIsPrimaryTransform(AssetId primaryId) : super(primaryId);
}

class StringDeclaringTransform extends StringConsumableTransform
    implements DeclaringTransform {
  final List<AssetId> outputs = [];

  StringDeclaringTransform(AssetId primaryId) : super(primaryId);

  @override
  void declareOutput(AssetId id) {
    outputs.add(id);
  }
}

class StringTransform extends StringConsumableTransform implements Transform {
  final StringAssets assets = new StringAssets();
  final StringAssets outputs = new StringAssets();

  // only string supported for now
  StringTransform(StringAsset asset, StringAssets inputAssets)
      : super(asset.id) {
    if (inputAssets != null) {
      inputAssets.forEach((id, asset) {
        assets[id] = asset;
      });
    }
    assets[primaryId] = asset;
  }

  @override
  Future<String> readInputAsString(AssetId id, {Encoding encoding}) async {
    StringAsset asset = assets[id];
    if (asset == null) {
      return null;
    }
    return asset.content;
  }

  @override
  Future<String> readPrimaryAsString({Encoding encoding}) async {
    return readInputAsString(primaryId, encoding: encoding);
  }

  @override
  Future<bool> hasInput(AssetId id) async {
    return assets.containsKey(id);
  }

  @override
  void addOutputFromString(AssetId id, String content, {Encoding encoding}) {
    outputs[id] = new StringAsset(id as MemoryAssetId, content);
  }
}
