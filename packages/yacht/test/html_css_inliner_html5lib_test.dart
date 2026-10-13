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
    test('fixCssInline link without href', () async {
      var src = join(outDir, 'no_href_src.html');
      var dst = join(outDir, 'no_href.html');
      await File(src).writeAsString(
        '<!doctype html><html><head>'
        '<link class="yacht-inline" rel="stylesheet">'
        '</head><body></body></html>',
      );
      await fixCssInline(src, dst);
      expect(await File(dst).readAsString(), contains('<link'));
    });
  });
}
