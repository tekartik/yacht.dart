library yacht.test.assetid_utils_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/assetid_utils.dart';
import 'package:path/path.dart';

main() {
  group('assetid_utils', () {
    test('withPath', () {
      String dir = posix.join('dir');
      AssetId id = new AssetId(null, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      id = assetIdWithPath(id, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      // package
      id = assetIdWithPath(id, 'packages/pkg/dir');
      expect(id.package, 'pkg');
      expect(id.path, posix.join("lib", dir));

      // null id
      id = assetIdWithPath(null, 'dir');
      expect(id.package, isNull);
      expect(id.path, dir);
      id = assetIdWithPath(null, 'packages/pkg/dir');
      expect(id.package, 'pkg');
      expect(id.path, posix.join("lib", dir));
    });
  });
}
