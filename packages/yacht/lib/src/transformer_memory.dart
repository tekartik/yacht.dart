library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:tekartik_yacht/src/assetid_utils.dart';

import 'transformer.dart';

class MemoryAssetId implements AssetId {
  @override
  final String? package;

  @override
  final String path;

  MemoryAssetId(this.package, this.path);

  @override

  /// Returns a new [AssetId] with the same [package] and [path] as this one
  /// but with file extension [newExtension].
  AssetId changeExtension(String newExtension) =>
      MemoryAssetId(package, p.withoutExtension(path) + newExtension);

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) {
    return (other is MemoryAssetId) &&
        ((other.package == package) && (other.path == path));
  }

  @override
  String toString() {
    if (package != null) {
      return 'package:$package/$path';
    }
    return path;
  }
}

/// generate the target assetId for a given path
AssetId assetIdWithPath(AssetId? id, String path) {
  path = normalizePath(path);

  var normalized = false;

  var firstPart = posix.split(path)[0];
  if (firstPart == '.' || firstPart == '..') {
    if (id != null) {
      path = posix.normalize(posix.join(posix.dirname(id.path), path));
    }
    normalized = true;
  }
  String? package;

  // resolve other package?
  if (path.startsWith(posix.join('packages', ''))) {
    var parts = posix.split(path);
    // 0 is packages
    if (parts.length > 2) {
      package = parts[1];
    }
    // Beware append 'lib' here to only get what is exported
    path = posix.joinAll(parts.sublist(2));
    path = posix.join('lib', path);
  } else {
    // default id
    if (id != null) {
      package = id.package;

      // try relative
      if ((!normalized) && (!posix.isAbsolute(path))) {
        var dirname = posix.dirname(id.path);
        // Don't join .
        if (dirname != '.') {
          path = posix.join(dirname, path);
        }
      }
    }
  }
  return MemoryAssetId(package, path);
}

class StringAsset {
  MemoryAssetId id;
  String? content;

  StringAsset(this.id, this.content);

  @override
  String toString() => '$id:$content';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is StringAsset) {
      return other.id == id && other.content == content;
    }
    return false;
  }
}

class StringAssets extends MapBase<AssetId, StringAsset> {
  Map<AssetId, StringAsset> assets = {};

  @override
  StringAsset? remove(Object? key) => assets.remove(key);

  @override
  Iterable<AssetId> get keys => assets.keys;

  @override
  void clear() {
    assets.clear();
  }

  @override
  StringAsset? operator [](Object? key) => assets[key as AssetId];

  @override
  operator []=(AssetId key, StringAsset value) => assets[key] = value;
}

StringAsset stringAsset(AssetId id, String? content) =>
    StringAsset(id as MemoryAssetId, content);

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
  bool? isConsumed;

  TransformLogger? get logger => null;

  StringConsumableTransform(super.primaryId);

  @override
  void consumePrimary() {
    isConsumed = true;
  }
}

class StringIsPrimaryTransform extends StringAssetTransform
    implements IsPrimaryTransform {
  StringIsPrimaryTransform(super.primaryId);
}

class StringDeclaringTransform extends StringConsumableTransform
    implements DeclaringTransform {
  final List<AssetId> outputs = [];

  StringDeclaringTransform(super.primaryId);

  @override
  void declareOutput(AssetId id) {
    outputs.add(id);
  }
}

class StringTransform extends StringConsumableTransform implements Transform {
  final StringAssets assets = StringAssets();
  final StringAssets outputs = StringAssets();

  // only string supported for now
  StringTransform(StringAsset asset, StringAssets inputAssets)
      : super(asset.id) {
    inputAssets.forEach((id, asset) {
      assets[id] = asset;
    });

    assets[primaryId] = asset;
  }

  @override
  Future<String?> readInputAsString(AssetId id, {Encoding? encoding}) async {
    var asset = assets[id];
    if (asset == null) {
      return null;
    }
    return asset.content;
  }

  @override
  Future<String?> readPrimaryAsString({Encoding? encoding}) async {
    return readInputAsString(primaryId, encoding: encoding);
  }

  @override
  Future<bool> hasInput(AssetId id) async {
    return assets.containsKey(id);
  }

  @override
  void addOutputFromString(AssetId id, String content, {Encoding? encoding}) {
    outputs[id] = StringAsset(id as MemoryAssetId, content);
  }
}
