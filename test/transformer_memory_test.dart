import 'package:dev_test/test.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'package:yacht/src/transformer.dart';

export 'package:yacht/src/transformer_memory.dart';

stringAssets(List data) {
  StringAssets assets = new StringAssets();

  // parse ['pkg'], 'path,' 'content'
  _add(List item) {
    try {
      int index = 0;
      String package;
      if (item.length > 2) {
        package = item[index++];
      }
      String path = item[index++];
      String content = item[index++];
      AssetId id = new MemoryAssetId(package, path);
      assets[id] = stringAsset(id, content);
    } catch (e) {
      throw new ArgumentError('Cannot parse ${item} ${e}');
    }
  }

  if (data.isNotEmpty) {
    if (data.first is List) {
      for (var item in data) {
        _add(item);
      }
    } else {
      _add(data);
    }
  }
  return assets;
}

main() {
  group('transformer_memory', () {
    test('stringAsset', () {
      StringAsset asset1 = stringAsset(assetIdWithPath(null, ''), null);
      StringAsset asset2 = stringAsset(assetIdWithPath(null, ''), null);
      expect(asset1, asset2);
      asset2 = stringAsset(assetIdWithPath(null, 'in'), null);
      expect(asset1, isNot(asset2));
      asset2 = stringAsset(assetIdWithPath(null, ''), 'content');
      expect(asset1, isNot(asset2));
    });

    test('stringAssets', () {
      StringAssets assets = stringAssets(['.', null]);
      AssetId id = assetIdWithPath(null, '');
      expect(assets.length, 1);
      StringAsset asset1 = assets[id];
      StringAsset asset2 = stringAsset(id, null);
      expect(asset1, asset2);

      // package
      assets = stringAssets(['pkg', 'asset', null]);
      id = new MemoryAssetId("pkg", 'asset');
      expect(assets.length, 1);
      expect(assets[id], stringAsset(id, null));

      StringAssets assets1 = stringAssets(['', null]);
      StringAssets assets2 = stringAssets(['', null]);
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
