library;

import 'package:tekartik_yacht/src/text_utils.dart';
import 'package:test/test.dart';

void main() {
  group('text_utils', () {
    test('utilsTrimText', () async {
      expect(utilsTrimText(' test '), 'test');
      expect(utilsTrimText(''), '');
    });
    test('beginsWithWhitespaces', () async {
      expect(beginsWithWhitespaces('test'), false);
      expect(beginsWithWhitespaces(' test'), true);
      expect(beginsWithWhitespaces(''), false);
    });
    test('endsWithWhitespaces', () async {
      expect(endsWithWhitespaces(' test'), false);
      expect(endsWithWhitespaces('test '), true);
      expect(endsWithWhitespaces(''), false);
    });
  });
}
