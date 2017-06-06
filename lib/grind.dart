import 'package:grinder/grinder.dart';
import 'package:yacht/build.dart';

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
  //await buildRunner.watch(buildRunnerSassPhase);
  await buildRunner.watch(phase);
}

@Task()
build() async {
  await buildRunner.build(phase);
}
