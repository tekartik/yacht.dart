// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_html/html_html5lib.dart';
import 'package:yacht/src/html_printer_common.dart';
import 'package:yacht/src/yacht.dart';

Future<void> main(List<String> args) async {
  var htmlProvider = htmlProviderHtml5Lib;
  var index = htmlProvider.createDocument();
  var body = index.body;
  body.appendChild(htmlProvider.createElementHtml('<h1>Yacht example</h1>'));
  var top = 'example';
  var files = await Directory(top)
      .list(recursive: true)
      .map((fse) => relative(fse.path, from: top))
      .where((name) => extension(name) == '.html')
      .toList();

  void appUlToBody() {
    var ul = htmlProvider.createElementTag('ul');
    body.appendChild(ul);
    for (var file in files) {
      var li = htmlProvider.createElementTag('li');

      ul.appendChild(li);
      li.appendChild(
          htmlProvider.createElementHtml('<a href="$file">$file</a>'));
      if (basename(file).startsWith('amp_')) {
        li = htmlProvider.createElementTag('li');
        ul.appendChild(li);
        li.appendChild(htmlProvider.createElementHtml(
            '<a href="$file#development=1">$file#development=1</a>'));
      }
    }
  }

  appUlToBody();
  var result = htmlPrintDocument(index,
      options: HtmlPrinterOptions(isWindows: Platform.isWindows));
  stdout.writeln(result);
  await File(join('example', 'index.html')).writeAsString(result);

  index = htmlProvider.createDocument(title: 'Amp Yacht example');
  body = index.body;
  var html = index.html;
  html.setAttribute('⚡', '');
  body.appendChild(
      htmlProvider.createElementHtml('<h1>Amp Yacht example</h1>'));
  var head = index.head;
  var children = htmlProvider
      .createElementHtml('<head>$yachtAmpBoilerplate</head>', noValidate: true)
      .childNodes;
  print(children);
  head.appendChild(htmlProvider.createTextNode('\n'));
  for (var child in List.of(children)) {
    print(child);
    head.appendChild(child);
    //head.appendChild(htmlProvider.createTextNode('\n'));
  }
  head.appendChild(htmlProvider.createTextNode('\n'));
  appUlToBody();
  result = htmlPrintDocument(index,
      options: HtmlPrinterOptions(isWindows: Platform.isWindows));
  print(result);
  await File(join('example', 'amp_index.html')).writeAsString(result);
  /*
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
        dstFilePath: join(outputDir.path, file));
  }*/
}
