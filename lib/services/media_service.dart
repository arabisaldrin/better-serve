import 'dart:io';

import 'package:better_serve/models/media.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaService with ChangeNotifier {
  bool loadingMedia = true;

  final List<Media> images = List.empty(growable: true);
  final List<Media> icons = List.empty(growable: true);

  bool get hasImages => images.isNotEmpty;
  bool get hasIcons => icons.isNotEmpty;

  MediaService() {
    loadMedia();
  }

  Future<void> loadMedia() async {
    await loadProductImages();
    await loadIcons();
    loadingMedia = false;
    notifyListeners();
  }

  Future loadProductImages() async {
    images.clear();
    images.addAll(await getMedia("products"));
  }

  Future loadIcons() async {
    icons.clear();
    icons.addAll(await getMedia("icons"));
  }

  Future<List<Media>> getMedia(String path) async {
    StorageResponse<List<FileObject>> res =
        await supabase.storage.from("images").list(path: path);
    if (res.hasError) {
      return List.empty(growable: true);
    }

    return res.data!.map((e) => Media("/$path/${e.name}")).toList();
  }

  Future uploadMedia(File file, String path) async {
    if (path.endsWith('/')) {
      path = path.substring(0, path.lastIndexOf('/'));
    }
    await supabase.storage
        .from("images")
        .upload("$path/${basename(file.path)}", file);

    await loadMedia();
  }

  Future uploadProductImage(File file) async {
    await uploadMedia(file, "/products");
    await loadProductImages();
    notifyListeners();
  }

  Future uploadIcon(File file) async {
    await uploadMedia(file, "/icons");
    await loadIcons();
    notifyListeners();
  }

  Future deleteMedia(List<String> paths) async {
    await supabase.storage.from("images").remove(paths);
    await loadMedia();
  }
}
