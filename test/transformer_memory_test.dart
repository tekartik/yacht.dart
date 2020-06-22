import 'package:dev_test/test.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'package:yacht/src/transformer.dart';

export 'package:yacht/src/transformer_memory.dart';

StringAssets stringAssets(List data) {
  var assets = StringAssets();

  // parse ['pkg'], 'path,' 'content'
  void _add(List<String> item) {
    try {
      var index = 0;
      String package;
      if (item.length > 2) {
        package = item[index++];
      }
      var path = item[index++];
      var content = item[index++];
      AssetId id = MemoryAssetId(package, path);
      assets[id] = stringAsset(id, content);
    } catch (e) {
      throw ArgumentError('Cannot parse ${item} ${e}');
    }
  }

  if (data.isNotEmpty) {
    if (data.first is List) {
      for (var item in data) {
        _add((item as List)?.cast<String>());
      }
    } else {
      _add(data.cast<String>());
    }
  }
  return assets;
}

void main() {
  group('transformer_memory', () {
    test('stringAsset', () {
      var asset1 = stringAsset(assetIdWithPath(null, ''), null);
      var asset2 = stringAsset(assetIdWithPath(null, ''), null);
      expect(asset1, asset2);
      asset2 = stringAsset(assetIdWithPath(null, 'in'), null);
      expect(asset1, isNot(asset2));
      asset2 = stringAsset(assetIdWithPath(null, ''), 'content');
      expect(asset1, isNot(asset2));
    });

    test('stringAssets', () {
      var assets = stringAssets(['.', null]);
      var id = assetIdWithPath(null, '');
      expect(assets.length, 1);
      var asset1 = assets[id];
      var asset2 = stringAsset(id, null);
      expect(asset1, asset2);

      // package
      assets = stringAssets(['pkg', 'asset', null]);
      id = MemoryAssetId('pkg', 'asset');
      expect(assets.length, 1);
      expect(assets[id], stringAsset(id, null));

      var assets1 = stringAssets(['', null]);
      var assets2 = stringAssets(['', null]);
      expect(assets1, assets2);
      assets2 = stringAssets([null, '', null]);
      expect(assets1, assets2);
      assets2 = stringAssets([
        ['', null]
      ]);
      expect(assets1, assets2);
      assets2 = stringAssets([
        [null, '', null]
      ]);
      expect(assets1, assets2);
      assets2 = stringAssets(['in', null]);
      expect(assets1, isNot(assets2));
      assets2 = stringAssets(['', 'content']);
      expect(assets1, isNot(assets2));
//expect
    });
  });
}
