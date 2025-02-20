import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_html/html_universal.dart';

import 'html_printer_test.dart';
import 'html_visitor_test.dart';
import 'yacht_common_test.dart';

void allTests(HtmlProvider htmlProvider) {
  groupVisitor(htmlProvider);
  groupPrinter(htmlProvider);
  groupYacht(htmlProvider);
}

Future<void> main() async {
  allTests(htmlProviderHtml5Lib);
  if (kDartIsWeb) {
    allTests(htmlProviderWeb);
  }
}
