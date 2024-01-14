import 'dart:io';

import 'package:emage_editor/component/footer.dart';
import 'package:emage_editor/component/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;

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

  void onDeleteItem() {}

  void onSaveImage() {}

  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.image = image;
    });
  }

  Widget renderBody() {
    if (image != null) {
      return Positioned.fill(
          child: InteractiveViewer(
              child: Image.file(
        File(image!.path),
        fit: BoxFit.cover,
      )));
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: onPickImage,
          child: const Text('Pick Image'),
        ),
      );
    }
  }
}
