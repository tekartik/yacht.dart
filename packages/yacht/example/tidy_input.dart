import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_yacht/yacht_io.dart';

Future<void> main(List<String> args) async {
  var inputDir = Directory(join('example', 'input'));
  var files = await inputDir
      .list()
      .map((fse) => basename(fse.path))
      .where((name) => extension(name) == '.html')
      .toList();
  var outputDir = Directory(join('example', 'output'));
  await outputDir.create(recursive: true);
  for (var file in files) {
    await tidyHtml(
      srcFilePath: join(inputDir.path, file),
      dstFilePath: join(outputDir.path, file),
    );
  }
}
