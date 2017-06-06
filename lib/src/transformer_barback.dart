library tekartik_barback.transformer_barback;

import 'dart:async';

import 'package:source_span/source_span.dart' as source_span;
import 'package:barback/barback.dart' as brbck;
export 'transformer.dart';
import 'package:yacht/src/assetid_utils.dart';
import 'transformer.dart' hide Asset, AssetId, Transformer, Transform;
import 'transformer.dart' as common;
import 'package:path/path.dart';

import 'dart:convert';

class BarbackAssetId implements common.AssetId {
  brbck.AssetId _impl;
  BarbackAssetId.wrap(brbck.AssetId assetId) {
    _impl = assetId;
  }

  @override
  String get path => _impl.path;

  @override
  String get package => _impl.package;

  @override
  common.AssetId changeExtension(String newExtension) =>
      _wrapAssetId(_impl.changeExtension(newExtension));

  @override
  toString() => _impl.toString();

  @override
  int get hashCode => _impl.hashCode;

  @override
  bool operator ==(o) => (o is BarbackAssetId) && (o._impl == _impl);
}

bool _isExplicitelyRelative(String path) {
  String firstPart = posix.split(path)[0];
  if (firstPart == '.' || firstPart == '..') {
    return true;
  }
  return false;
}

/// generate the target assetId for a given path
brbck.AssetId assetIdWithPath(brbck.AssetId id, String path) {
  if (path == null) {
    return null;
  }

  bool isRelative = _isExplicitelyRelative(path);
  path = normalizePath(path);

  //bool normalized = false;

  //devPrint("~ ${id} - $path");
  //String firstPart = posix.split(path)[0];
  if (isRelative) {
    path = posix.normalize(join(posix.dirname(id.path), path));
    //normalized = true;
  }
  String package;

  // resolve other package?
  if (path.startsWith(posix.join("packages", ""))) {
    List<String> parts = posix.split(path);
    // 0 is packages
    if (parts.length > 2) {
      package = parts[1];
    }
    // Beware append "lib" here to only get what is exported
    path = posix.joinAll(parts.sublist(2));
    path = posix.join("lib", path);
  } else {
    // default id
    if (id != null) {
      package = id.package;

      // try relative
      //if ((!normalized) && (!posix.isAbsolute(path))) {
      /*
      if ((!normalized) && _isExplicitelyRelative(path)) {)
        path = posix.join(posix.dirname(id.path), path);
      }
      */
    }
  }
  return new brbck.AssetId(package, path);
}

common.AssetId _wrapAssetId(brbck.AssetId id) {
  return new BarbackAssetId.wrap(id);
}

brbck.AssetId _unwrapAssetId(common.AssetId id) {
  return (id as BarbackAssetId)._impl;
}

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

  isPrimary(brbck.AssetId id) => isAssetPrimary(new BarbackAssetId.wrap(id));
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
  void declareOutput(common.AssetId id) =>
      transform.declareOutput(_unwrapAssetId(id));

  @override
  common.AssetId get primaryId => _wrapAssetId(transform.primaryId);
}

/**
 * Used in transformers
 */
class BarbackTransform extends BarbackPrimaryTransform
    implements common.Transform {
  brbck.Transform transform;
  BarbackTransform.wrap(this.transform);

  @override
  common.AssetId get primaryId => _wrapAssetId(transform.primaryInput.id);

  // add the content in a given asset
  @override
  common.AssetId addOutputFromString(common.AssetId id, String content,
      {Encoding encoding}) {
    transform
        .addOutput(new brbck.Asset.fromString(_unwrapAssetId(id), content));
    return id;
  }

  @override
  Future<String> readPrimaryAsString({Encoding encoding}) =>
      transform.primaryInput.readAsString(encoding: encoding);

  @override
  Future<String> readInputAsString(common.AssetId id, {Encoding encoding}) {
    return transform.readInputAsString(_unwrapAssetId(id), encoding: encoding);
  }

  @override
  Future<bool> hasInput(common.AssetId id) =>
      transform.hasInput(_unwrapAssetId(id));

  @override
  TransformLogger get logger => new BarbackTransformLogger(transform.logger);

  @override
  void consumePrimary() => transform.consumePrimary();

  @override
  common.AssetId newAssetId(common.AssetId assetId, String path) {
    return _wrapAssetId(assetIdWithPath(
        _unwrapAssetId(assetId), path)); //new brbck.AssetId(package, path));
  }
}

/// Object used to report warnings and errors encountered while running a
/// transformer.
class BarbackTransformLogger implements TransformLogger {
  brbck.TransformLogger _impl;

  BarbackTransformLogger(this._impl);

  @override
  void info(String message,
          {common.AssetId asset, source_span.SourceSpan span}) =>
      _impl.info(message, asset: _unwrapAssetId(asset), span: span);

  @override
  void fine(String message,
          {common.AssetId asset, source_span.SourceSpan span}) =>
      _impl.fine(message, asset: _unwrapAssetId(asset), span: span);

  @override
  void warning(String message,
          {common.AssetId asset, source_span.SourceSpan span}) =>
      _impl.warning(message, asset: _unwrapAssetId(asset), span: span);

  @override
  void error(String message,
          {common.AssetId asset, source_span.SourceSpan span}) =>
      _impl.error(message, asset: _unwrapAssetId(asset), span: span);
}
