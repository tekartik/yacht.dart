import 'package:dev_build/shell.dart';

Future<void> main(List<String> args) async {
  await run('dart test -p chrome test/test_runner_web_test.dart');
}
