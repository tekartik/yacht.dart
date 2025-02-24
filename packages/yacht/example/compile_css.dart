// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_yacht/src/csslib_utils.dart';

Future<void> main(List<String> args) async {
  var css = File(join('lib', 'src', 'mvp', 'mvp.css')).readAsStringSync();
  var minified = compileCss(css, polyfill: false, pretty: false);
  await File(join('lib', 'src', 'mvp', 'mvp_min.css')).writeAsString(minified);
  print(minified);
}
