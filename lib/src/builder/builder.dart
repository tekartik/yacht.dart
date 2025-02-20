import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:build/build.dart' as build;
import 'package:source_span/source_span.dart' as source_span;
import 'package:yacht/src/transformer.dart';
import 'package:yacht/src/transformer.dart' as common;
/*
export 'transformer.dart';
*/

class BuilderAssetId extends common.AssetId {
  build.AssetId? _impl;

  BuilderAssetId.wrap(build.AssetId assetId) {
    _impl = assetId;
  }

  @override
  common.AssetId changeExtension(String newExtension) =>
      _wrapAssetId(_impl!.changeExtension(newExtension));

  @override
  String get package => _impl!.package;

  @override
  String get path => _impl!.path;

  @override
  String toString() => _impl.toString();

  @override
  int get hashCode => _impl.hashCode;

  @override
  bool operator ==(Object other) =>
      (other is BuilderAssetId) && (other._impl == _impl);
}

common.AssetId _wrapAssetId(build.AssetId id) {
  return BuilderAssetId.wrap(id);
}

build.AssetId? _unwrapAssetId(common.AssetId id) {
  return (id as BuilderAssetId)._impl;
}

// for declaration
abstract class TransformBuilder implements build.Builder, common.Transformer {
  @override
  Future build(BuildStep buildStep) =>
      Future.sync(() => run(BuildStepTransform.wrap(buildStep)));

/*
  @override
  apply(brbck.Transform transform) => run(new BarbackTransform.wrap(transform));

  @override
  declareOutputs(brbck.DeclaringTransform transform) =>
      run(new BarbackDeclaringTransform.wrap(transform));
      */
}

/*
class BarbackDeclaringTransform extends BarbackPrimaryTransform
    implements common.DeclaringTransform {
  // either darback.Transform or
  brbck.DeclaringTransform transform;
  BarbackDeclaringTransform.wrap(this.transform);

  @override
  void consumePrimary() => transform.consumePrimary();

  @override
  TransformLogger get logger => new BarbackTransformLogger(transform.logger);

  @override
  void declareOutput(AssetId id) => transform.declareOutput(id);

  @override
  AssetId get primaryId => transform.primaryId;
}
*/

/// Used in transformers
class BuildStepTransform implements Transform //extends BarbackPrimaryTransform
//  implements common.Transform
{
  build.BuildStep buildStep;

  BuildStepTransform.wrap(this.buildStep);

  @override
  void addOutputFromString(common.AssetId assetId, String content,
      {Encoding? encoding = utf8}) {
    buildStep.writeAsString(_unwrapAssetId(assetId)!, content,
        encoding: encoding!);
  }

  @override
  void consumePrimary() {
    // TODO: implement consumePrimary
  }

  @override
  Future<bool> hasInput(common.AssetId id) {
    // TODO: implement hasInput - confirm
    return buildStep.canRead(_unwrapAssetId(id)!);
  }

  @override
  TransformLogger get logger => BuildTransformLogger();

  @override
  common.AssetId newAssetId(common.AssetId assetId, String path) {
    return _wrapAssetId(
        build.AssetId.resolve(Uri.parse(path), from: _unwrapAssetId(assetId)));
  }

  @override
  common.AssetId get primaryId => _wrapAssetId(buildStep.inputId);

  @override
  Future<String> readInputAsString(common.AssetId id,
      {Encoding? encoding = utf8}) {
    return buildStep.readAsString(_unwrapAssetId(id)!, encoding: encoding!);
  }

  @override
  Future<String> readPrimaryAsString({Encoding? encoding = utf8}) {
    return readInputAsString(primaryId, encoding: encoding);
  }
}

/// Object used to report warnings and errors encountered while running a
/// transformer.
class BuildTransformLogger implements TransformLogger {
  // BuildTransformLogger();

  @override
  void info(String message,
          {common.AssetId? asset, source_span.SourceSpan? span}) =>
      //_impl.info(message, asset: asset, span: span);
      // ignore: avoid_print
      print('INFO: $message');

  @override
  void fine(String message,
          {common.AssetId? asset, source_span.SourceSpan? span}) =>
      //_impl.fine(message, asset: asset, span: span);
      // ignore: avoid_print
      print('FINE: $message');

  @override
  void warning(String message,
          {common.AssetId? asset, source_span.SourceSpan? span}) =>
      //_impl.warning(message, asset: asset, span: span);
      // ignore: avoid_print
      print('WARN: $message');

  @override
  void error(String message,
          {common.AssetId? asset, source_span.SourceSpan? span}) =>
      //_impl.error(message, asset: asset, span: span);
      // ignore: avoid_print
      print('ERR: $message');
}
