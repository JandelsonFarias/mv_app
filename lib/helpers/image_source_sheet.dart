import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {

  final Function(File) onImageSelected;

  ImageSourceSheet({this.onImageSelected});

  void imageSelected(File image) async {
    onImageSelected(image);
  }

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.camera_alt),
                Text("Câmera")
              ],
            ),
            onPressed: () async {
              final pickedFile = await picker.getImage(source: ImageSource.camera);

              if (pickedFile != null){
                imageSelected(File(pickedFile.path));
              }
              else
                imageSelected(null);
            },
          ),
          FlatButton(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.folder),
                Text("Galeria")
              ],
            ),
            onPressed: () async {
              final pickedFile = await picker.getImage(source: ImageSource.gallery);

              if (pickedFile != null){
                imageSelected(File(pickedFile.path));
              }
              else
                imageSelected(null);
            },
          )
        ],
      ),
    );
  }
}
