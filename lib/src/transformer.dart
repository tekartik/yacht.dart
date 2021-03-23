library tekartik_barback.transformer;

import 'dart:async';

import 'dart:convert';
//import 'package:barback/src/asset/asset_id.dart';
//export 'package:barback/src/asset/asset_id.dart';
import 'package:source_span/source_span.dart' as source_span;

abstract class AssetId {
  String get path;

  String? get package;

  AssetId changeExtension(String newExtension);
}

/// A blob of content.
///
/// Assets may come from the file system, or as the output of a [Transformer].
/// They are identified by [AssetId].
///
/// Custom implementations of [Asset] are not currently supported.
abstract class Asset {
  /// The ID for this asset.
  AssetId get id;

  /// Returns the contents of the asset as a string.
  ///
  /// If the asset was created from a [String] the original string is always
  /// returned and [encoding] is ignored. Otherwise, the binary data of the
  /// asset is decoded using [encoding], which defaults to [utf8].
  Future<String> readAsString({Encoding encoding = utf8});
}

/// A set of [Asset]s with distinct IDs.
///
/// This uses the [AssetId] of each asset to determine uniqueness, so no two
/// assets with the same ID can be in the set.
abstract class AssetSet implements Iterable<Asset> {
  /// The ids of the assets in the set.
  Iterable<AssetId> get ids;

  AssetSet();

  /// Creates a new AssetSet from the contents of [other].
  ///
  /// If multiple assets in [other] have the same id, the last one takes
  /// precedence.
  /*
  AssetSet.from(Iterable<Asset> other) {
    for (var asset in other) {
      _assets[asset.id] = asset;
    }
  }
  */

  @override
  Iterator<Asset> get iterator;

  @override
  int get length;

  /// Gets the [Asset] in the set with [id], or returns `null` if no asset with
  /// that ID is present.
  Asset operator [](AssetId id);

  /// Adds [asset] to the set.
  ///
  /// If there is already an asset with that ID in the set, it is replaced by
  /// the new one. Returns [asset].
  Asset add(Asset asset);

  /// Adds [assets] to the set.
  void addAll(Iterable<Asset> assets);

  /// Returns `true` if the set contains [asset].
  @override
  bool contains(Object? asset);

  /// Returns `true` if the set contains an [Asset] with [id].
  bool containsId(AssetId id);

  /// If the set contains an [Asset] with [id], removes and returns it.
  Asset removeId(AssetId id);

  /// Removes all assets from the set.
  void clear();
}

abstract class TransformerImpl {
  /// Run this transformer on the primary input specified by [transform].
  ///
  /// The [transform] is used by the [Transformer] for two purposes (in
  /// addition to accessing the primary input). It can call `getInput()` to
  /// request additional input assets. It also calls `addOutput()` to provide
  /// generated assets back to the system. Either can be called multiple times,
  /// in any order.
  ///
  /// In other words, a Transformer's job is to find all inputs for a
  /// transform, starting at the primary input, then generate all output assets
  /// and yield them back to the transform.
  ///
  /// If this does asynchronous work, it should return a [Future] that completes
  /// once it's finished.
  Future apply(Transform transform);
}

/*
// List never null
Future<TransformerContext> transformerBuildDir(TransformerImpl transformer, String pubPackageRoot) {
  //devPrint(topPath);
  List<Future> futures = [];

  List<Transform> transforms = [];

  TransformerContext _context;
  TransformerContext getContext() {
    if (_context == null) {
      _context = new TransformerContext(pubPackageRoot);
    }
    return _context;
  }
  return new Directory(pubPackageRoot).list(recursive: true, followLinks: false).listen((FileSystemEntity fse) {
    //devPrint(FileSystemEntity.type(fse.path));

    futures.add(FileSystemEntity.isFile(fse.path).then((bool isFile) {
      if (isFile) {


        String path = relative(fse.path, from: pubPackageRoot);
        //devPrint(fse);
        //devPrint(pubPackageRoot);
        //devPrint(path);

        AssetId assetId = new AssetId(packageName, path);
        Asset asset = new Asset.fromPath(assetId, fse.path);

        Transform transform = new Transform(asset, context: getContext());

        return asFuture(transformer.isPrimary(assetId)).then((bool isPrimary) {
          if (isPrimary) {
            return transformer.apply(transform).then((_) {
              // Add it
              transforms.add(transform);
            });
          }
        });


        //_packageName
//          return fse.stat().then((FileStat stat) {
//            //devPrint('${stat.size} ${fse}');
//            size += stat.size;
//          });
      }
    }));
  }).asFuture().then((_) {
    return Future.wait(futures).then((_) {
      //return size;
      return _context;
    });
  });
}
*/

// Super class must implement Transformer
abstract class TransformerMixin implements Transformer {
  // can be overriden
  @override
  String? get allowedExtensions => null;

  // can be overriden
  bool isPrimary(AssetId id) {
    // Allow all files if [primaryExtensions] is not overridden.
    if (allowedExtensions == null) return true;

    for (var extension in allowedExtensions!.split(' ')) {
      if (id.path.endsWith(extension)) return true;
    }

    return false;
  }
}

/// A [Transformer] represents a processor that takes in one or more input
/// assets and uses them to generate one or more output assets.
///
/// Dart2js, a SASS->CSS processor, a CSS spriter, and a tool to concatenate
/// files are all examples of transformers. To define your own transformation
/// step, extend (or implement) this class.
///
/// If possible, transformers should implement [DeclaringTransformer] as well to
/// help barback optimize the package graph.
abstract class Transformer {
  /// Override this to return a space-separated list of file extensions that are
  /// allowed for the primary inputs to this transformer.
  ///
  /// Each extension must begin with a leading `.`.
  ///
  /// If you don't override [isPrimary] yourself, it defaults to allowing any
  /// asset whose extension matches one of the ones returned by this. If you
  /// don't override [isPrimary] *or* this, it allows all files.
  String? get allowedExtensions;

  /// Returns `true` if [id] can be a primary input for this transformer.
  ///
  /// While a transformer can read from multiple input files, one must be the
  /// 'primary' input. This asset determines whether the transformation should
  /// be run at all. If the primary input is removed, the transformer will no
  /// longer be run.
  ///
  /// A concrete example is dart2js. When you run dart2js, it will traverse
  /// all of the imports in your Dart source files and use the contents of all
  /// of those to generate the final JS. However you still run dart2js 'on' a
  /// single file: the entrypoint Dart file that has your `main()` method.
  /// This entrypoint file would be the primary input.
  ///
  /// If this is not overridden, defaults to allow any asset whose extension
  /// matches one of the ones returned by [allowedExtensions]. If *that* is
  /// not overridden, allows all assets.
  ///
  /// This may return a `Future<bool>` or, if it's entirely synchronous, a
  /// `bool`.
  FutureOr<bool> isAssetPrimary(AssetId id);

  /// Run this transformer on the primary input specified by [transform].
  ///
  /// The [transform] is used by the [Transformer] for two purposes (in
  /// addition to accessing the primary input). It can call `getInput()` to
  /// request additional input assets. It also calls `addOutput()` to provide
  /// generated assets back to the system. Either can be called multiple times,
  /// in any order.
  ///
  /// In other words, a Transformer's job is to find all inputs for a
  /// transform, starting at the primary input, then generate all output assets
  /// and yield them back to the transform.
  ///
  /// If this does asynchronous work, it should return a [Future] that completes
  /// once it's finished.
  FutureOr run(AssetTransform transform);
}

/// While a [Transformer] represents a *kind* of transformation, this defines
/// one specific usage of it on a set of files.
///
/// This ephemeral object exists only during an actual transform application to
/// facilitate communication between the [Transformer] and the code hosting
/// the transformation. It lets the [Transformer] access inputs and generate
/// outputs.
abstract class Transform extends ConsumableTransform {
  // Read the primary asset
  Future<String?> readPrimaryAsString({Encoding? encoding});

  // add the content in a given asset
  void addOutputFromString(AssetId assetId, String content,
      {Encoding? encoding});

  //@deprecated
  //Asset get primaryInput;

  /// A logger so that the [Transformer] can report build details.
  //TransformLogger get logger => _aggregate.logger;
  TransformLogger? get logger;

  /*
  Transform(this.primaryInput);

  Transform._(this._aggregate, this.primaryInput);
  */

  /// Gets the asset for an input [id].
  ///
  /// If an input with [id] cannot be found, throws an [AssetNotFoundException].
  //Future<Asset> getInput(AssetId id); // => _aggregate.getInput(id);

  /// A convenience method to the contents of the input with [id] as a string.
  ///
  /// This is equivalent to calling [getInput] followed by [Asset.readAsString].
  ///
  /// If the asset was created from a [String] the original string is always
  /// returned and [encoding] is ignored. Otherwise, the binary data of the
  /// asset is decoded using [encoding], which defaults to [utf8].
  ///
  /// If an input with [id] cannot be found, throws an [AssetNotFoundException].
  Future<String?> readInputAsString(AssetId id, {Encoding? encoding});

  /// A convenience method to return whether or not an asset exists.
  ///
  /// This is equivalent to calling [getInput] and catching an
  /// [AssetNotFoundException].
  Future<bool> hasInput(AssetId id);

  // Create a new asset id
  AssetId newAssetId(AssetId assetId, String path);

  /// Stores [output] as an output created by this transformation.
  ///
  /// A transformation can output as many assets as it wants.
  // void addOutput(Asset output);

  /// Consume the primary input so that it doesn't get processed by future
  /// phases or emitted once processing has finished.
  ///
  /// Normally the primary input will automatically be forwarded unless the
  /// transformer overwrites it by emitting an input with the same id. This
  /// allows the transformer to tell barback not to forward the primary input
  /// even if it's not overwritten.
  @override
  void consumePrimary(); // => _aggregate.consumePrimary(primaryInput.id);
}

/*
/// An interface for [Transformer]s that can cheaply figure out which assets
/// they'll emit without doing the work of actually creating those assets.
///
/// If a transformer implements this interface, that allows barback to perform
/// optimizations to make the asset graph work more smoothly.
abstract class DeclaringTransformer extends PrimaryTransform {
  /// Declare which assets would be emitted for the primary input id specified
  /// by [transform].
  ///
  /// This works a little like [Transformer.apply], with two main differences.
  /// First, instead of having access to the primary input's contents, it only
  /// has access to its id. Second, instead of emitting [Asset]s, it just emits
  /// [AssetId]s through [transform.addOutputId].
  ///
  /// If this does asynchronous work, it should return a [Future] that completes
  /// once it's finished.
  declareOutputs(DeclaringTransform transform);
}
*/

abstract class ConsumableTransform extends AssetTransform {
  /// Consume the primary input so that it doesn't get processed by future
  /// phases or emitted once processing has finished.
  ///
  /// Normally the primary input will automatically be forwarded unless the
  /// transformer overwrites it by emitting an input with the same id. This
  /// allows the transformer to tell barback not to forward the primary input
  /// even if it's not overwritten.
  void consumePrimary();
}

abstract class AssetTransform {
  /// Gets the primary input asset id
  ///
  /// While a transformation can use multiple input assets, one must be a
  /// special 'primary' asset. This will be the 'entrypoint' or 'main' input
  /// file for a transformation.
  ///
  /// For example, with a dart2js transform, the primary input would be the
  /// entrypoint Dart file. All of the other Dart files that that imports
  /// would be secondary inputs.
  AssetId get primaryId;
}

abstract class IsPrimaryTransform extends AssetTransform {}

///abstract class DecratingTransform
/// A transform for [DeclaringTransformer]s that allows them to declare the ids
/// of the outputs they'll generate without generating the concrete bodies of
/// those outputs.
abstract class DeclaringTransform extends ConsumableTransform {
  /// A logger so that the [Transformer] can report build details.
  TransformLogger? get logger;

  /// Stores [id] as the id of an output that will be created by this
  /// transformation when it's run.
  ///
  /// A transformation can declare as many assets as it wants. If
  /// [DeclaringTransformer.declareOutputs] declareds a given asset id for a
  /// given input, [Transformer.apply] should emit the corresponding asset as
  /// well.
  void declareOutput(AssetId id);
}

/// The severity of a logged message.
class LogLevel {
  static const info = LogLevel('Info');
  static const fine = LogLevel('Fine');
  static const warning = LogLevel('Warning');
  static const error = LogLevel('Error');

  // Deprecated since v0.4.0 2020-04-05
  @deprecated
  // ignore: constant_identifier_names
  static const INFO = info;
  @deprecated
  // ignore: constant_identifier_names
  static const FINE = fine;
  @deprecated
  // ignore: constant_identifier_names
  static const WARNING = warning;
  @deprecated
  // ignore: constant_identifier_names
  static const ERROR = error;

  final String name;
  const LogLevel(this.name);

  @override
  String toString() => name;
}

typedef LogFunction = void Function(
    AssetId asset, LogLevel level, String message, source_span.SourceSpan span);

/// Object used to report warnings and errors encountered while running a
/// transformer.
abstract class TransformLogger {
  /// Logs an informative message.
  ///
  /// If [asset] is provided, the log entry is associated with that asset.
  /// Otherwise it's associated with the primary input of [transformer]. If
  /// present, [span] indicates the location in the input asset that caused the
  /// error.
  void info(String message, {AssetId? asset, source_span.SourceSpan? span});

  /// Logs a message that won't be displayed unless the user is running in
  /// verbose mode.
  ///
  /// If [asset] is provided, the log entry is associated with that asset.
  /// Otherwise it's associated with the primary input of [transformer]. If
  /// present, [span] indicates the location in the input asset that caused the
  /// error.
  void fine(String message, {AssetId? asset, source_span.SourceSpan? span});

  /// Logs a warning message.
  ///
  /// If [asset] is provided, the log entry is associated with that asset.
  /// Otherwise it's associated with the primary input of [transformer]. If
  /// present, [span] indicates the location in the input asset that caused the
  /// error.
  void warning(String message, {AssetId? asset, source_span.SourceSpan? span});

  /// Logs an error message.
  ///
  /// If [asset] is provided, the log entry is associated with that asset.
  /// Otherwise it's associated with the primary input of [transformer]. If
  /// present, [span] indicates the location in the input asset that caused the
  /// error.
  ///
  /// Logging any errors will cause Barback to consider the transformation to
  /// have failed, much like throwing an exception. This means that neither the
  /// primary input nor any outputs emitted by the transformer will be passed on
  /// to the following phase, and the build will be reported as having failed.
  ///
  /// Unlike throwing an exception, this doesn't cause a transformer to stop
  /// running. This makes it useful in cases where a single input may have
  /// multiple errors that the user wants to know about.
  void error(String message, {AssetId? asset, source_span.SourceSpan? span});
}
