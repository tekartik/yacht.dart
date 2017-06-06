import 'package:barback/barback.dart';
import 'package:dev_test/test.dart';
import 'package:yacht/src/assetid_utils.dart';
import 'package:yacht/src/transformer_barback.dart' hide AssetId;
import 'package:path/path.dart';

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

      // not relative
      id = assetIdWithPath(id, 'sub');
      expect(id.path, posix.join("sub"));

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

    test('sub_folder', () {
      AssetId id = new AssetId('pkg', 'sub/file');
      // package
      id = assetIdWithPath(id, '../dir');
      expect(id.package, 'pkg');
      expect(id.path, "dir");
    });

    test('package sub_folder', () {
      AssetId id = new AssetId('pkg', 'sub/file');
      // package
      id = assetIdWithPath(id, '../packages/pkg/dir');
      expect(id.package, 'pkg');
      expect(id.path, posix.join("lib", "dir"));
    });

    test('sub new', () {
      AssetId id = new AssetId('pkg', 'sub/file');
      // package
      id = assetIdWithPath(id, 'sub/file2');
      expect(id.package, 'pkg');
      expect(id.path, posix.join("sub", "file2"));
    });
  });
}
