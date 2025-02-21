import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_yacht/src/assetid_utils.dart';

import 'transformer_memory_test.dart';

void main() {
  group('assetid_utils', () {
    test('withPath', () {
      var dir = posix.join('dir');
      var id = assetIdWithPath(null, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      id = assetIdWithPath(id, dir);
      expect(id.package, isNull);
      expect(id.path, dir);

      // relative
      id = assetIdWithPath(id, 'dir/sub');
      expect(id.path, posix.join('dir/sub'));

      id = assetIdWithPath(id, './other/file');
      expect(id.path, posix.join('dir/other/file'));

      id = assetIdWithPath(id, '../sub');
      expect(id.path, posix.join('dir/sub'));

      // package
      id = assetIdWithPath(id, 'packages/pkg/dir');
      expect(id.package, 'pkg');
      expect(id.path, posix.join('lib', dir));

      // null id
      id = assetIdWithPath(null, 'dir');
      expect(id.package, isNull);
      expect(id.path, dir);
      id = assetIdWithPath(null, 'packages/pkg/dir');
      expect(id.package, 'pkg');
      expect(id.path, posix.join('lib', dir));
    });

    test('normalizePath', () {
      expect(normalizePath('a/b'), 'a/b');
      expect(normalizePath('a/../b'), 'b');
      expect(normalizePath('a\\b'), 'a/b');
    });
  });
}
