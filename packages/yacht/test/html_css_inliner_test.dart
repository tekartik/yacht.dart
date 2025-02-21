@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_yacht/src/html_css_inliner.dart';

import 'test_common.dart';

String outDir = join('.dart_tool', 'yacht');

void main() {
  group('html_css_inliner', () {
    setUp(() async {
      try {
        await Directory(outDir).create(recursive: true);
      } catch (_) {}
    });
    test('fixCssInline', () async {
      await fixCssInline(
        join('test', 'data', 'html_css_inliner', 'index1.html'),
        join(outDir, 'index1.html'),
      );
      await fixCssInline(
        join('test', 'data', 'html_css_inliner', 'index2.html'),
        join(outDir, 'index2.html'),
      );

      expect(
        await File(join(outDir, 'index2.html')).readAsString(),
        contains('<style data-custom>body { color: red; }</style>'),
      );
    });
  });
}
