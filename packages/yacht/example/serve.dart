import 'package:dev_build/shell.dart';
import 'package:process_run/stdio.dart';

Future<void> main(List<String> args) async {
  stdout.writeln('http://localhost:8080');
  await Shell().cd('example').run('dhttpd .');
}
