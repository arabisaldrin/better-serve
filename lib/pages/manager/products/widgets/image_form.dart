import 'dart:io';

import 'package:better_serve/models/media.dart';
import 'package:better_serve/services/media_service.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';

class ImageForm extends StatefulWidget {
  final String? image;
  final ValueChanged<String?> callback;
  final String? filter;
  const ImageForm(this.image, this.callback, {Key? key, this.filter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageFormState();
}

class _ImageFormState extends State<ImageForm> {
  String? selected;

  late SettingsService settings;
  @override
  void initState() {
    selected = widget.image;
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
        tag: "image_select",
        width: 680,
        child: Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: const [
                      Icon(Icons.image),
                      Text("Select Image"),
                    ],
                  )),
              const Divider(
                height: 2,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  child: Consumer<MediaService>(
                    builder: (context, media, _) {
                      if (media.hasImages) {
                        return Wrap(alignment: WrapAlignment.center, children: [
                          for (var item in media.images) imageCard(item)
                        ]);
                      }
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            widget.callback(null);
                          },
                          child: const Text("Cancel")),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            FilePickerResult? filePickerResult =
                                await FilePicker.platform.pickFiles();

                            if (filePickerResult != null) {
                              var pickedFile = File(filePickerResult
                                  .files.single.path
                                  .toString());
                              await uploadProductImage(pickedFile);
                              setState(() {});
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.upload,
                                size: 15,
                              ),
                              Text("Upload New"),
                            ],
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: selected != null
                                ? () {
                                    widget.callback(selected);
                                  }
                                : null,
                            child: const Text("Ok")),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  Widget imageCard(Media item) {
    double imageSize = 100;
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: imageSize,
          height: imageSize,
          child: Stack(
            children: [
              CachedNetworkImage(
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                imageUrl: publicPath("/images/products/${item.name}"),
                errorWidget: (context, url, error) {
                  return Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Icon(Icons.error),
                  );
                },
              ),
              if (selected == item.name)
                Container(
                  color: settings.primaryColor.withAlpha(50),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selected = item.name;
                    });
                  },
                ),
              ),
              // Positioned(
              //     bottom: 0,
              //     left: 0,
              //     right: 0,
              //     child: Container(
              //       decoration: const BoxDecoration(
              //           gradient: LinearGradient(
              //               colors: [Colors.black, Colors.transparent],
              //               begin: Alignment.bottomCenter,
              //               end: Alignment.topCenter)),
              //       padding: const EdgeInsets.symmetric(horizontal: 5),
              //       child: Text(
              //         item.name.substring(0, item.name.lastIndexOf(".")),
              //         style: const TextStyle(color: Colors.white),
              //       ),
              //     ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadProductImage(File file) async {
    await supabase.storage
        .from("images")
        .upload("/products/${basename(file.path)}", file);
  }
}
