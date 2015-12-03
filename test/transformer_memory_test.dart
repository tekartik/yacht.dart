library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'package:yacht/src/transformer.dart';

stringAssets(List data) {
  StringAssets assets = new StringAssets();

  _add(List item) {
    try {
      int index = 0;
      String package;
      if (item.length > 2) {
        package = item[index++];
      }
      String path = item[index++];
      String content = item[index++];
      AssetId id = new AssetId(package, path);
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
      StringAsset asset1 = stringAsset(new AssetId(null, ''), null);
      StringAsset asset2 = stringAsset(new AssetId(null, ''), null);
      expect(asset1, asset2);
      asset2 = stringAsset(new AssetId(null, 'in'), null);
      expect(asset1, isNot(asset2));
      asset2 = stringAsset(new AssetId(null, ''), 'content');
      expect(asset1, isNot(asset2));
    });
    test('stringAssets', () {
      StringAssets assets = stringAssets(['', null]);
      AssetId id = new AssetId(null, '');
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
