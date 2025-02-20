@TestOn('browser')
library;

import 'package:tekartik_html/html_web.dart';
import 'package:test/test.dart';

import 'test_runner_test.dart';

Future<void> main() async {
  allTests(htmlProviderWeb);
}
