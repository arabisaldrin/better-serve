import 'package:better_serve/utils/constants.dart';
import 'package:path/path.dart';

class Media {
  final String path;

  String get name => basename(url);
  String get url => publicPath("/images/$path");

  Media(this.path);
}
