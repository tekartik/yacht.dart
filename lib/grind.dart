import 'dart:async';

import 'package:grinder/grinder.dart';

void yachtGrind(List<String> args) {
  if (args.isEmpty) {
    grind(['--help']);
  } else {
    grind(args);
  }
}

@Task()
Future test() => TestRunner().testAsync();

@DefaultTask()
@Task()
Future init() async {
  //await grind(['--help']);
}

@Depends(test)
@Task()
Future pubbuild() async {
  Pub.build();
}

@Task()
void clean() => defaultClean();

/*
@Task()
watch() async {
  //await buildRunner.watch(buildRunnerSassPhase);
  await buildRunner.watch(phase);
}

@Task()
build() async {
  await buildRunner.build(phase);
}
*/
