#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/build.dart \
  lib/grind.dart \
  lib/yacht.dart

pub run test -p vm,firefox,chrome