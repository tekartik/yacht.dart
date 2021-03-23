import 'dart:io';

import 'package:html/dom.dart';
import 'package:path/path.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:yacht/src/html_visitor.dart';

/// Tidy a file, if [dstFilePath] is ommited, original file is replaced
Future tidyHtml({required String srcFilePath, String? dstFilePath}) async {
  dstFilePath ??= srcFilePath;
  var src = await File(srcFilePath).readAsString();
  var builder = HtmlDocumentVisitor();
  builder.visitDocument(Document.html(src));

  var result = htmlPrintDocument(Document.html(src));
  try {
    await Directory(dirname(dstFilePath)).create(recursive: true);
  } catch (_) {}
  await File(dstFilePath).writeAsString(result);
}
