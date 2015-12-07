library yacht_example_simple.test.test_common;

import 'dart:convert';
import 'package:path/path.dart';
import 'dart:mirrors';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptDir => dirname(_TestUtils.scriptPath);
String get projectTop => dirname(testScriptDir);

String html({String body, String head}) {
  StringBuffer sb = new StringBuffer();
  sb.writeln('<!doctype html>');
  sb.writeln('<html>');
  sb.write('<head>');
  if (head != null) {
    sb.writeln('');
    Iterable<String> headParts = LineSplitter.split(head);
    for (String line in headParts) {
      sb.writeln('  $line');
    }
  }
  sb.writeln('</head>');
  sb.write('<body>');

  if (body != null) {
    sb.writeln('');
    Iterable<String> bodyParts = LineSplitter.split(body);
    for (String line in bodyParts) {
      sb.writeln('  $line');
    }
  }
  sb.writeln('</body>');
  sb.write('</html>');
  return sb.toString();
}
