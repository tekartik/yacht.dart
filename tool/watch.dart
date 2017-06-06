import 'dart:async';

import 'package:yacht/build.dart';

Future main() async {
  await buildRunner.watch(phase);
  //await watch(new PhaseGroup()..addPhase(phase));
}
