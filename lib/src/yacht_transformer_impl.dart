library yacht_transformer.src.yacht_transformer_impl;

import 'transformer.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:yacht_transformer/src/html_printer.dart';
import 'package:yacht_transformer/src/html_visitor.dart';
import 'package:html/dom.dart';

class _YachtIsPrimaryTransform extends AssetTransform
    implements IsPrimaryTransform {
  final AssetId primaryId;
  _YachtIsPrimaryTransform(this.primaryId);
}

abstract class YachtTransformerMixin {
  BarbackSettings get settings;
  // YachtTransformer.asPlugin([BarbackSettings settings]) : super.asPlugin(settings);

  // Override to set a flag
  bool setIsPrimary(bool isPrimary) => isPrimary;

  run(AssetTransform transform) {
    AssetId primaryId = transform.primaryId;
    String basename = posix.basename(primaryId.path);
    String extension = posix.extension(basename);

    bool isPrimary = true;
    // handle part
    if (!(extension == '.html' || extension == '.css')) {
      isPrimary = false;
    }

    if (transform is IsPrimaryTransform) {
      // return as primary
      return setIsPrimary(isPrimary);
    } else if (!isPrimary) {
      // abort here
      return null;
    }

    bool isMaster = true;
    if (basename.startsWith('_')) {
      isMaster = false;
    }
    if (isMaster) {
      String basenameWithoutExtenstion =
          posix.basenameWithoutExtension(basename);
      String subExtension = posix.extension(basenameWithoutExtenstion);

      // handle part
      if (subExtension == '.part') {
        isMaster = false;
      }
    }

    // if not master, consume it
    if (!isMaster) {
      if (transform is ConsumableTransform) {
        transform.consumePrimary();
      }
      return null;
    }

    if (transform is DeclaringTransform) {
      transform.declareOutput(primaryId);
      return null;
    }

    // Need to read content now...
    return new Future.sync(() async {
      if (transform is Transform) {
        String input = await transform.readPrimaryAsString();

        // only for testing
        if (input == null) {
          return null;
        }

        // trim extra spaces as data after </html> might include TEXT_NODE in the body
        Document document = new Document.html(input.trim());

        HtmlPrinterOptions options =
            new HtmlPrinterOptions.fromBarbackSettings(settings);
        // print
        String output = await htmlPrintDocument(document, options: options);

        if (false) {
          // quick debug
          HtmlDocumentNodeLinesPrinter builder =
              new HtmlDocumentNodeLinesPrinter();
          await builder.visitDocument(document);
          print('nodes: ${builder.lines}');

          HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
          await printer.visitDocument(document);
          print('lines: ${printer.lines}');

          print('input: ${input}');
          print('output: ${output}');
        }

        transform.addOutputFromString(primaryId, output);
      } else {
        throw 'should not get there';
      }
    });

/*
    if (transform is DeclaringTransform) {
      transform.declareOutput(transform.primaryId);
    } else if (transform is Transform) {
      // let it go
      // transform.a

    }
    // handle part - sub
    // declare ourself as output
    //transform.declareOutput(transform.primaryId);
*/
  }

  // @override
  String get allowedExtensions => '.html .css .js';

  // @override
  isPrimary(AssetId id) {
    IsPrimaryTransform transform = new _YachtIsPrimaryTransform(id);
    return run(transform);

    /*
    // Allow all files if [primaryExtensions] is not overridden.
    bool isPrimary = false;
    for (var extension in allowedExtensions.split(" ")) {
      if (id.path.endsWith(extension)) {
        isPrimary = true;
        break;
      }
    }

    if (isPrimary) {
      if (posix.basename(id.path).startsWith('no_')) {
        return false;
      }

      // ok
      return true;
    }

    return false;
    */
  }
}
