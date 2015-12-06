library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';

main() {
  //YachtTransformer transformer;
  group('yacht_option', () {
    group('options', () {
      test('default', () {
        YachtTransformOption option =
            new YachtTransformOption.fromBarbackSettings(null);
        expect(option.isDebug, isFalse);
        expect(option.isRelease, isTrue);
        expect(option.isImport, isTrue);
        option.import = false;
        expect(option.isImport, isFalse);
        option.import = 'debug';
        expect(option.isImport, isFalse);
        option.import = true;
        expect(option.isImport, isTrue);
        option.import = 'release';
        expect(option.isImport, isTrue);

        // import
        option.debug = true;
        option.import = null;
        expect(option.isImport, isTrue);
        option.import = true;
        expect(option.isImport, isTrue);
        option.import = 'debug';
        expect(option.isImport, isTrue);
        option.import = 'release';
        expect(option.isImport, isFalse);
        option.import = false;
        expect(option.isImport, isFalse);

        // ignored
        expect(option.ignored, []);
      });

      test('barback', () {
        YachtTransformOption option =
            new YachtTransformOption.fromBarbackSettings(new BarbackSettings({
          'import': 'debug',
          'ignore': [
            'ignored.css',
            'example/ignored1.css',
            'example/ignored2.css'
          ]
        }, BarbackMode.DEBUG));
        expect(option.isDebug, isTrue);
        expect(option.isRelease, isFalse);
        expect(option.isImport, isTrue);
        expect(option.ignored,
            ['ignored.css', 'example/ignored1.css', 'example/ignored2.css']);
      });
    });
  });
}
