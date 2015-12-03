library yacht_transformer.src.transformer_memory;

import 'transformer.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:collection';

class StringAsset {
  AssetId id;
  String content;
  StringAsset(this.id, this.content);

  @override
  toString() => '$id:$content';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(StringAsset o) {
    if (o is StringAsset) {
      return o.id == id && o.content == content;
    }
    return false;
  }
}

class StringAssets extends MapBase<AssetId, StringAsset> {
  Map<AssetId, StringAsset> assets = {};

  @override
  StringAsset remove(AssetId id) => assets.remove(id);

  @override
  Iterable<AssetId> get keys => assets.keys;

  @override
  void clear() {
    assets.clear();
  }

  StringAsset operator [](AssetId id) => assets[id];
  operator []=(AssetId id, StringAsset asset) => assets[id] = asset;
}

StringAsset stringAsset(AssetId id, String content) =>
    new StringAsset(id, content);

class StringAssetTransform implements AssetTransform {
  @override
  final AssetId primaryId;

  StringAssetTransform(this.primaryId);
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
    outputs[id] = new StringAsset(id, content);
  }
}
