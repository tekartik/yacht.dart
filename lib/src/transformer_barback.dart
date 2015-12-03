library tekartik_barback.transformer_barback;

import 'dart:async';

import 'package:source_span/source_span.dart' as source_span;
import 'package:barback/barback.dart' as brbck;
export 'transformer.dart';
import 'transformer.dart' hide Asset, Transformer, Transform;
import 'transformer.dart' as common;

import 'dart:convert';

// for declaration
abstract class BarbackTransformer extends brbck.Transformer
    implements brbck.DeclaringTransformer, common.Transformer {
  BarbackSettings settings;
  BarbackTransformer.asPlugin(this.settings);

  @override
  apply(brbck.Transform transform) => run(new BarbackTransform.wrap(transform));

  @override
  declareOutputs(brbck.DeclaringTransform transform) =>
      run(new BarbackDeclaringTransform.wrap(transform));
}

abstract class BarbackPrimaryTransform implements common.AssetTransform {
  BarbackPrimaryTransform();

  /*
  factory BarbackPrimaryTransform.wrap(dynamic transform) {
    if (transform is brbck.DeclaringTransform) {
      return new BarbackDeclaringTransform.wrap(transform);
    } else if (transform is brbck.Transform) {
      return new BarbackTransform.wrap(transform);
    } else {
      throw new InvalidArgumentError('not supported ${tranform}');
    }
  }
  */

}

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

/**
 * Used in transformers
 */
class BarbackTransform extends BarbackPrimaryTransform
    implements common.Transform {
  brbck.Transform transform;
  BarbackTransform.wrap(this.transform);

  @override
  AssetId get primaryId => transform.primaryInput.id;

  // add the content in a given asset
  @override
  AssetId addOutputFromString(AssetId id, String content, {Encoding encoding}) {
    transform.addOutput(new brbck.Asset.fromString(id, content));
    return id;
  }

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

  @override
  void consumePrimary() => transform.consumePrimary();
}

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
