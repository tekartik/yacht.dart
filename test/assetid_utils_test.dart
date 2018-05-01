import 'package:dev_test/test.dart';
import 'package:yacht/src/assetid_utils.dart';
import 'package:path/path.dart';
import 'package:yacht/src/transformer.dart';

import 'transformer_memory_test.dart';

main() {
  group('assetid_utils', () {
    test('withPath', () {
      String dir = posix.join('dir');
      AssetId id = assetIdWithPath(null, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      id = assetIdWithPath(id, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      // relative
      id = assetIdWithPath(id, 'dir/sub');
      expect(id.path, posix.join("dir/sub"));

      id = assetIdWithPath(id, './other/file');
      expect(id.path, posix.join("dir/other/file"));

      id = assetIdWithPath(id, '../sub');
      expect(id.path, posix.join("dir/sub"));

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

    test('normalizePath', () {
      expect(normalizePath("a/b"), "a/b");
      expect(normalizePath("a/../b"), "b");
      expect(normalizePath("a\\b"), "a/b");
    });
  });
}
