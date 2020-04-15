import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yacht/src/common_import.dart';

const String argHelpFlag = 'help';
const String argVersionFlag = 'version';
const String argVerboseFlag = 'verbose';
const String argOfflineFlag = 'offline';
const String argDryRunFlag = 'dry-run';

final Version binVersion = Version(0, 1, 0);

Future main(List<String> args) async {
  void _addHelp(ArgParser parser) {
    parser.addFlag(argHelpFlag, abbr: 'h', help: 'Help info');
  }

  var parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag(argDryRunFlag, abbr: 'd', help: 'Don\'t execture the command');
  _addHelp(parser);
  parser.addFlag(argVersionFlag, help: 'Version', negatable: false);
  parser.addFlag(argVerboseFlag,
      abbr: 'v', help: 'verbose output', negatable: false);

  var result = parser.parse(args);

  void _version() {
    stdout.write('$binVersion');
  }

  void _help() {
    stdout.writeln('General utility');
    stdout.writeln();
    stdout.writeln(parser.usage);
    stdout.writeln(parser.commands.keys);
  }

  final version = result[argVersionFlag] as bool;
  if (version) {
    _version();
    return;
  }
  final help = result[argHelpFlag] as bool;
  if (help) {
    _help();
    return;
  }

  if (result.rest.isEmpty) {
    _help();
    return;
  }
}
