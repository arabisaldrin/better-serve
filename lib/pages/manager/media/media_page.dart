import 'dart:io';

import 'package:better_serve/components/simple_chip.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/models/media.dart';
import 'package:better_serve/services/media_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

enum MediaType {
  image,
  icon;
}

class _MediaPageState extends State<MediaPage> {
  List<String> selected = List.empty(growable: true);
  bool deleting = false;
  bool uploading = false;
  MediaType mediaType = MediaType.image;
  late SettingsService _settings;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (selected.isNotEmpty) {
          setState(() {
            selected.clear();
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Consumer2<MediaService, SettingsService>(
        builder: (BuildContext context, media, settings, _) {
          _settings = settings;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SimpleChip(
                      text: "Images",
                      selected: mediaType == MediaType.image,
                      onTap: () {
                        setState(() {
                          selected.clear();
                          mediaType = MediaType.image;
                        });
                      },
                      color: settings.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    SimpleChip(
                      text: "Icons",
                      selected: mediaType == MediaType.icon,
                      onTap: () {
                        setState(() {
                          selected.clear();
                          mediaType = MediaType.icon;
                        });
                      },
                      color: settings.primaryColor,
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        firstChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mediaType == MediaType.image
                                  ? "(${media.images.length}) Images"
                                  : "(${media.icons.length}) Icons",
                              style: const TextStyle(fontSize: 20),
                            ),
                            ElevatedButton(
                                onPressed: uploading
                                    ? null
                                    : () async {
                                        FilePickerResult? filePickerResult =
                                            await FilePicker.platform
                                                .pickFiles();

                                        if (filePickerResult != null) {
                                          setState(() {
                                            uploading = true;
                                          });
                                          // ignore: use_build_context_synchronously
                                          showLoading(primaryContext);
                                          var pickedFile = File(filePickerResult
                                              .files.single.path
                                              .toString());
                                          String path =
                                              mediaType == MediaType.image
                                                  ? "/products/"
                                                  : "/icons/";
                                          await media
                                              .uploadMedia(pickedFile, path)
                                              .then((value) {
                                            setState(() {
                                              uploading = false;
                                            });
                                            Navigator.of(primaryContext).pop();
                                          });
                                        }
                                      },
                                child: Row(
                                  children: [
                                    if (uploading)
                                      const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      const Icon(Icons.upload_outlined),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text("Upload"),
                                  ],
                                )),
                          ],
                        ),
                        secondChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "(${selected.length}) Selected",
                              style: const TextStyle(fontSize: 20),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: deleting
                                    ? null
                                    : () {
                                        setState(() {
                                          deleting = true;
                                        });
                                        List<String> paths;
                                        if (mediaType == MediaType.image) {
                                          paths = selected
                                              .map((e) => "products/$e")
                                              .toList();
                                        } else {
                                          paths = selected
                                              .map((e) => "icons/$e")
                                              .toList();
                                        }
                                        media.deleteMedia(paths).then((value) {
                                          showToast(
                                              context,
                                              const Text(
                                                  "Selected Media Deleted!"));
                                          setState(() {
                                            selected.clear();
                                            deleting = false;
                                          });
                                        });
                                      },
                                child: SizedBox(
                                  width: 70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: deleting
                                        ? [
                                            const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ))
                                          ]
                                        : const [
                                            Icon(Icons.delete_outline),
                                            Text("Delete"),
                                          ],
                                  ),
                                )),
                          ],
                        ),
                        crossFadeState: selected.isEmpty
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
              ),
              media.loadingMedia
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Loading...")
                        ],
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            if (mediaType == MediaType.image)
                              for (Media item in media.images) imageCard(item)
                            else
                              for (Media item in media.icons) imageCard(item)
                          ],
                        ),
                      ),
                    )
            ],
          );
        },
      ),
    );
  }

  Widget imageCard(Media item) {
    double size = mediaType == MediaType.image ? 150 : 100;
    return Card(
      elevation: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(mediaType == MediaType.image ? 0 : 15),
                child: CachedNetworkImage(
                  fadeInDuration: const Duration(milliseconds: 100),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  placeholderFadeInDuration: const Duration(milliseconds: 100),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                          alignment: Alignment.center,
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                image: DecorationImage(image: _settings.logo)),
                          )),
                  imageUrl: item.url,
                  errorWidget: (context, url, error) {
                    return const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.error),
                    );
                  },
                ),
              ),
              if (selected.contains(item.name))
                Container(
                  color: _settings.primaryColor.withAlpha(50),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              if (selected.contains(item.name) && deleting)
                Container(
                  color: Colors.red.withAlpha(50),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (selected.contains(item.name)) {
                        selected.remove(item.name);
                      } else if (selected.isNotEmpty) {
                        selected.add(item.name);
                      }
                    });
                  },
                  onLongPress: () {
                    setState(() {
                      selected.add(item.name);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
