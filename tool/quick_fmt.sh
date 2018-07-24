#!/bin/bash

# Fast fail the script on failures.
set -e

dartfmt -w lib test
dartanalyzer --fatal-warnings lib test

pub run test -p vm