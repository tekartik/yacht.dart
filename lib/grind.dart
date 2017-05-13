import 'package:build/build.dart';
import 'package:build_runner/build_runner.dart' as build_runner;
import 'package:build_runner/build_runner.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart';
import 'package:sass_builder/phase.dart';
import 'package:yacht/build.dart';
import 'package:yacht/src/build/build_runner_dev.dart';
import 'package:async/async.dart';
import 'package:yacht/src/common_import.dart';

yachtGrind(List<String> args) {
  if (args.isEmpty) {
    grind(['--help']);
  } else {
    grind(args);
  }
}
@Task()
test() => new TestRunner().testAsync();

@DefaultTask()
@Task()
init() async {
  //await grind(['--help']);
}

@Depends(test)
@Task()
pubbuild() {
  Pub.build();
}

@Task()
clean() => defaultClean();


@Task()
watch() async {
  await buildRunner.watch(buildRunnerSassPhase);
}

@Task()
build() async {
  await buildRunner.build(phase);
}