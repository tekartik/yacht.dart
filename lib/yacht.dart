library yacht;

//import 'package:barback/barback.dart' as barback;
import 'src/transformer_barback.dart';
import 'src/yacht_impl.dart';

///
/// YachtTransformer
///
/// Usage:
/// - add dependency
/// - add transformer
///
class YachtTransformer extends BarbackTransformer with YachtTransformerMixin {
  YachtTransformer.asPlugin([BarbackSettings settings])
      : super.asPlugin(settings);
}

/// Conditional
/// <title yacht-release>release</title>
/// <title yacht-debug>debug</title>
///

/// yacht.yaml
/// template:
///   yacht_template.html
/// src:
///   post/*.md
