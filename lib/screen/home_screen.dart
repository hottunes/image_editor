import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:emage_editor/component/emotion_sticker.dart';
import 'package:emage_editor/component/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../component/footer.dart';
import '../model/sticker_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedId;
  GlobalKey imgKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          renderBody(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MainAppBar(
              onSaveImage: onSaveImage,
              onDeleteItem: onDeleteItem,
              onPickImage: onPickImage,
            ),
          ),
          if (image != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Footer(
                onEmotionTap: onEmotionTap,
              ),
            )
        ],
      ),
    );
  }

  Widget renderBody() {
    if (image != null) {
      return RepaintBoundary(
        key: imgKey,
        child: InteractiveViewer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(image!.path),
                fit: BoxFit.cover,
              ),
              ...stickers.map((sticker) => Center(
                    child: EmotionSticker(
                      key: ObjectKey(sticker.id),
                      onTransform: () {
                        onTransform(sticker.id);
                      },
                      imgPath: sticker.imgPath,
                      isSelected: selectedId == sticker.id,
                    ),
                  ))
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: onPickImage,
          child: const Text("Pick Image"),
        ),
      );
    }
  }

  void onDeleteItem() async {
    setState(() {
      stickers = stickers.where((element) => element.id != selectedId).toSet();
    });
  }

  void onSaveImage() async {
    // Find the render boundary of the current widget
    RenderRepaintBoundary boundary =
        imgKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Convert the render boundary to an image
    ui.Image image = await boundary.toImage();

    // Convert the image to byte data in PNG format
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Save the image to the device's gallery using the ImageGallerySaver package
    await ImageGallerySaver.saveImage(pngBytes, quality: 100);

    // Display a Snackbar to inform the user that the image has been saved
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Image Saved')));
  }

  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.image = image;
    });
  }

  void onEmotionTap(int index) async {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(id: Uuid().v4(), imgPath: 'asset/img/emoticon_$index.png')
      };
    });
  }

  void onTransform(String id) {
    setState(() {
      selectedId = id;
    });
  }
}
