library yacht;

//import 'package:barback/barback.dart' as barback;
import 'src/transformer_barback.dart';
import 'src/yacht_impl.dart';

class YachtTransformer extends BarbackTransformer with YachtTransformerMixin {
  YachtTransformer.asPlugin([BarbackSettings settings])
      : super.asPlugin(settings);

  @override
  String get allowedExtensions => '.html .css .js';
}