import 'dart:async';

import 'package:build/build.dart';
import 'package:build/build.dart' as build;
/*
export 'transformer.dart';
*/
import '../transformer.dart' hide Asset, AssetId, Transformer, Transform;

import '../transformer.dart' as common;

class BuilderAssetId extends common.AssetId {
  build.AssetId _impl;

  BuilderAssetId.wrap(build.AssetId assetId) {
    _impl = assetId;
  }

  @override
  common.AssetId changeExtension(String newExtension) =>
      _wrapAssetId(_impl.changeExtension(newExtension));

  @override
  String get package => _impl.package;

  @override
  String get path => _impl.path;

  @override
  toString() => _impl.toString();

  @override
  int get hashCode => _impl.hashCode;

  @override
  bool operator ==(o) => (o is BuilderAssetId) && (o._impl == _impl);
}

common.AssetId _wrapAssetId(build.AssetId id) {
  return new BuilderAssetId.wrap(id);
}

/*
build.AssetId _unwrapAssetId(common.AssetId id) {
  return (id as BuilderAssetId)._impl;
}
*/

// for declaration
abstract class TransformBuilder implements build.Builder, common.Transformer {
  Future build(BuildStep buildStep) =>
      run(new BuildStepTransform.wrap(buildStep));

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

/**
 * Used in transformers
 */
class BuildStepTransform implements AssetTransform
//extends BarbackPrimaryTransform
//  implements common.Transform
{
  build.BuildStep buildStep;
  BuildStepTransform.wrap(this.buildStep);
/*
  @override
  AssetId get primaryId => transform.primaryInput.id;

  // add the content in a given asset
  @override
  AssetId addOutputFromString(AssetId id, String content, {Encoding encoding}) {
    buildStep.writeAsString(id, content);
    //transform.addOutput(new brbck.Asset.fromString(id, content));
    return id;
  }
*/
  /*
  @override
  Future<String> readPrimaryAsString({Encoding encoding}) =>
      transform.primaryInput.readAsString(encoding: encoding);

  @override
  Future<String> readInputAsString(AssetId id, {Encoding encoding}) {
    return transform.readInputAsString(id, encoding: encoding);
  }

  @override
  Future<bool> hasInput(AssetId id) => transform.hasInput(id);
  @override
  TransformLogger get logger => new BarbackTransformLogger(transform.logger);
  // TODO delete
  @override
  void consumePrimary() => {}
  */
  // TODO: implement primaryId
  @override
  common.AssetId get primaryId => _wrapAssetId(buildStep.inputId);
}

/*
/// Object used to report warnings and errors encountered while running a
/// transformer.
class BarbackTransformLogger implements TransformLogger {
  brbck.TransformLogger _impl;

  BarbackTransformLogger(this._impl);

  @override
  void info(String message, {AssetId asset, source_span.SourceSpan span}) =>
      _impl.info(message, asset: asset, span: span);

  @override
  void fine(String message, {AssetId asset, source_span.SourceSpan span}) =>
      _impl.fine(message, asset: asset, span: span);

  @override
  void warning(String message, {AssetId asset, source_span.SourceSpan span}) =>
      _impl.warning(message, asset: asset, span: span);

  @override
  void error(String message, {AssetId asset, source_span.SourceSpan span}) =>
      _impl.error(message, asset: asset, span: span);
}
*/
