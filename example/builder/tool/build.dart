import 'dart:async';

import 'package:yacht/build.dart';

Future main() async {
  await buildRunner.build(phase);
  //await build(new PhaseGroup()..addPhase(sassPhase));
}
