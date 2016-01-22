library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
import 'yacht_transformer_impl_test.dart';
import 'html_printer_test.dart';
import 'transformer_memory_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

const String simplePostMarkdown = '''
---
title: Simple post
---

* this title is: {{title}}
* it is a {{app.post}}
''';

const String simpleYachtYaml = '''
template:
  yacht_template.html
src:
  - index.md
''';

const String simpleTemplate = '''
<!DOCTYPE html><html><head></head><body>{{title}}</body></html>
''';

StringAssets simpleStringAssets = stringAssets([
  ['yacht.yaml', simpleYachtYaml],
  ['yacht_template.html', simpleTemplate]
]);

assetId(String path) => new AssetId(null, path);
main() {
  //YachtTransformer transformer;
  group('yacht_gen_impl', () {
    test('no_yacht_yaml', () async {
      await checkYachtTransformMarkdown(simplePostMarkdown, null, null
          /*
            htmlLines([
              [0, '<html>'],
              [1, '<head>'],
              [2, '<script async src="test.dart.js"></script>'],
              [1, '</head>'],
              [1, '<body>'],
              [1, '</body>'],
              [0, '</html>']
            ])
            */
          );
    });
    test('simple', () async {
      await checkYachtTransformMarkdown(
          simplePostMarkdown,
          simpleStringAssets,
          htmlLines([
            [0, '<html>'],
            [1, '<head></head>'],
            [1, '<body>Simple post</body>'],
            [0, '</html>']
          ]));
    });
  });
}
