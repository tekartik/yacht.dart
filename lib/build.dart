import 'package:build/build.dart';
import 'package:build_runner/build_runner.dart';
import 'package:sass_builder/phase.dart';
import 'package:yacht/src/build/build_runner_dev.dart';
import 'package:yacht/src/common_import.dart';
export 'src/build/build_runner_dev.dart';

BuildRunnerPhase get buildRunnerSassPhase {
  return buildRunnerPhase(new PhaseGroup()..addPhase(sassPhase), deleteFilesByDefault: true);
}

var _graph = new PackageGraph.forThisPackage();

/// A really simple [Builder], it just makes copies!
class CopyBuilder implements Builder {
  final String extension;

  CopyBuilder(this.extension);

  Future build(BuildStep buildStep) async {
    /// Each [buildStep] has a single input.
    var inputId = buildStep.inputId;

    /// Create a new target [AssetId] based on the old one.
    var copy = inputId.addExtension(extension);
    var contents = await buildStep.readAsString(inputId);

    /// Write out the new asset.
    ///
    /// There is no need to `await` here, the system handles waiting on these
    /// files as necessary before advancing to the next phase.
    buildStep.writeAsString(copy, contents);
  }

  /// Configure output extensions. All possible inputs match the empty input
  /// extension. For each input 1 output is created with `extension` appended to
  /// the path.
  Map<String, List<String>> get buildExtensions =>  {'': [extension]};

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

}

Phase get yachtHtmlPhase => new Phase()..addAction(
    new CopyBuilder(".copy"), new InputSet(_graph.root.name, ['**/*.yacht.html']));

BuildRunnerPhase get buildYachtHtmlPhase {
  return buildRunnerPhase(new PhaseGroup()..addPhase(yachtHtmlPhase), deleteFilesByDefault: false);
}
BuildRunner buildRunner = new BuildRunner();

BuildRunnerPhase get phase => buildRunnerPhase(null)..addPhase(yachtHtmlPhase)
  //..addPhase(sassPhase)
  ;


