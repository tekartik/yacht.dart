/// [tidyHtml] on files, `dart:io` only.
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht.dart';

/// Tidy the html file [srcFilePath] into [dstFilePath] (its folders are
/// created); if [dstFilePath] is omitted, the source file is replaced.
///
/// Parsed with [htmlProvider], `htmlProviderHtml5Lib` by default.
Future<void> tidyHtml({
  required String srcFilePath,
  String? dstFilePath,
  HtmlProvider? htmlProvider,
}) async {
  dstFilePath ??= srcFilePath;
  var src = await File(srcFilePath).readAsString();
  htmlProvider ??= htmlProviderHtml5Lib;
  var result = htmlProvider.yachtTidyHtml(src);

  try {
    await Directory(dirname(dstFilePath)).create(recursive: true);
  } catch (_) {}

  await File(dstFilePath).writeAsString(result);
}
