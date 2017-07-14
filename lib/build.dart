import 'package:barback/src/transformer/barback_settings.dart';
import 'package:build/build.dart';
//import 'package:build/build.dart' as build;
import 'package:build_runner/build_runner.dart';
//import 'package:sass_builder/phase.dart';
import 'package:html/dom.dart';
import 'package:yacht/src/builder/build_runner_dev.dart';
import 'package:yacht/src/builder/builder.dart';
import 'package:yacht/src/common_import.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:yacht/src/transformer.dart';
import 'package:yacht/src/transformer.dart' as common;
import 'package:yacht/src/yacht_impl.dart';
//export 'src/builder/build_runner_dev.dart';

/*
BuildRunnerPhase get buildRunnerSassPhase {
  return buildRunnerPhase(
      new PhaseGroup()
      //..addPhase(sassPhase)
      ,
      deleteFilesByDefault: true);
}
*/

var _graph = new PackageGraph.forThisPackage();

class YachtBuilder extends TransformBuilder
    with YachtTransformerMixin
    implements Builder {
  /*
  YachtTransformer.asPlugin([BarbackSettings settings])
      : super.asPlugin(settings);
      */
  @override
  Future build(BuildStep buildStep) async {
    //devPrint("running buildStep on ${buildStep.inputId}");
    await super.build(buildStep);
  }

  @override
  BarbackSettings get settings => null;

  @override
  Future transformHtml(Transform transform) async {
    common.AssetId primaryId = transform.primaryId;
    String input = await transform.readPrimaryAsString();

    // only for testing
    if (input == null) {
      return null;
    }

    // trim extra spaces as data after </html> might include TEXT_NODE in the body
    Document document = new Document.html(input.trim());

    HtmlPrinterOptions options =
        new HtmlPrinterOptions.fromBarbackSettings(settings);

    // Convert content
    // - include
    await handleElement(
        new HtmlTransform()
          ..transform = transform
          ..document = document,
        primaryId,
        document.documentElement);

    // Rewrite script
    if (!option.isDebug) {
      removeDartDotJsTags(document);
      rewriteDartTags(document);
    }
    // extract lines
    HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
    await printer.visitDocument(document);
    HtmlLines outHtmlLines = printer.lines;
    // test subclass my override this to get the lines emitted
    htmlLines = outHtmlLines;

    // print
    String output = await htmlPrintLines(outHtmlLines, options: options);

    /*
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
        */

    common.AssetId outputAssetId = primaryId.changeExtension(".g.html");

    transform.addOutputFromString(outputAssetId, output);
  }
}

/// A really simple [Builder], it just makes copies!
class CopyBuilder implements Builder {
  final String extension;

  CopyBuilder(this.extension);

  Future build(BuildStep buildStep) async {
    /// Each [buildStep] has a single input.
    var inputId = buildStep.inputId;

    /// Create a new target [common.AssetId] based on the old one.
    var copy = inputId.addExtension(extension);
    var contents = await buildStep.readAsString(inputId);

    /// Write out the new asset.
    ///
    /// There is no need to `await` here, the system handles waiting on these
    /// files as necessary before advancing to the next phase.
    await buildStep.writeAsString(copy, contents);
  }

  /// Configure output extensions. All possible inputs match the empty input
  /// extension. For each input 1 output is created with `extension` appended to
  /// the path.
  /// - If an empty key exists, all inputs are considered matching.
  Map<String, List<String>> get buildExtensions => {
        '': [extension]
      };

  /*
  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    /*
    if (!basename(inputId.path).startsWith('_')) {
      mainInputs.add(inputId);

      return [_changeExtension(inputId)];
    }
    */
    return [_changeExtension(inputId)];
  }
  */
  /*

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    // TODO: implement declareOutputs
    return null;
  }
  */
}

Phase get yachtHtmlPhase => new Phase()
  ..addAction(
      new YachtBuilder(), new InputSet(_graph.root.name, ['**/*.yacht.html']));

Phase get debugCopyPhase => new Phase()
  ..addAction(new CopyBuilder(".copy"),
      new InputSet(_graph.root.name, ['**/*.yacht.html']));

BuildRunnerPhase get buildYachtHtmlPhase {
  return buildRunnerPhase(new PhaseGroup()..addPhase(yachtHtmlPhase),
      deleteFilesByDefault: false);
}

BuildRunner buildRunner = new BuildRunner();

BuildRunnerPhase get phase => buildRunnerPhase(null)..addPhase(yachtHtmlPhase)
    //..addPhase(sassPhase)
    ;
