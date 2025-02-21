import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_yacht/src/common_import.dart';

const String argHelpFlag = 'help';
const String argVersionFlag = 'version';
const String argVerboseFlag = 'verbose';
const String argOfflineFlag = 'offline';
const String argDryRunFlag = 'dry-run';

final Version binVersion = Version(0, 1, 0);

Future main(List<String> args) async {
  void addHelp(ArgParser parser) {
    parser.addFlag(argHelpFlag, abbr: 'h', help: 'Help info');
  }

  var parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag(argDryRunFlag, abbr: 'd', help: 'Don\'t execute the command');
  addHelp(parser);
  parser.addFlag(argVersionFlag, help: 'Version', negatable: false);
  parser.addFlag(argVerboseFlag,
      abbr: 'v', help: 'verbose output', negatable: false);

  var result = parser.parse(args);

  void printVersion() {
    stdout.write('$binVersion');
  }

  void printHelp() {
    stdout.writeln('General utility');
    stdout.writeln();
    stdout.writeln(parser.usage);
    stdout.writeln(parser.commands.keys);
  }

  final version = result[argVersionFlag] as bool;
  if (version) {
    printVersion();
    return;
  }
  final help = result[argHelpFlag] as bool;
  if (help) {
    printHelp();
    return;
  }

  if (result.rest.isEmpty) {
    printHelp();
    return;
  }
}
