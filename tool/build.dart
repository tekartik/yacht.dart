import 'dart:async';

import 'package:build_runner/build_runner.dart';
import 'package:sass_builder/phase.dart';
import 'package:yacht/build.dart';

Future main() async {
  await buildRunner.build(phase);
  //await build(new PhaseGroup()..addPhase(sassPhase));
}