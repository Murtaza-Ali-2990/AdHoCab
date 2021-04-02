import 'dart:io';

import 'package:adhocab/utils/styles.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

typedef Callback = void Function(String val);

class UploadDocument extends StatefulWidget {
  final url, type, uid, callback;
  UploadDocument({this.url, this.type, this.uid, this.callback});

  _Upload createState() => _Upload(
        url: url,
        type: type,
        uid: uid,
        callback: callback,
      );
}

class _Upload extends State<UploadDocument> {
  String url, type, uid;
  final Callback callback;
  _Upload({this.url, this.type, this.uid, this.callback});

  bool loading = false;

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                constraints: BoxConstraints(maxHeight: 500, maxWidth: 500),
                child: loading
                    ? loadingStyle
                    : url == null || url.isEmpty
                        ? Image.network('https://i.imgur.com/sUFH1Aq.png')
                        : Image.network(url),
              ),
              SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: _upload,
                icon: Icon(Icons.cloud_upload),
                label: ButtonLayout('Upload $type'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _upload() async {
    setState(() => loading = true);

    final firebaseStorage = FirebaseStorage.instance;
    final imagePicker = ImagePicker();
    PickedFile image;

    try {
      await Permission.photos.request();
      var permissionStatus = await Permission.photos.status;

      if (!permissionStatus.isGranted) {
        print('Permission NOT Granted');
        setState(() => loading = false);
        return;
      }

      image = await imagePicker.getImage(source: ImageSource.gallery);

      if (image != null) {
        var file = File(image.path);
        var snapshot = await firebaseStorage
            .ref()
            .child('$uid/$type')
            .putFile(file)
            .whenComplete(() => null);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() => url = downloadUrl);
        callback(url);
      } else {
        print('No Image Path Received');
      }
    } catch (exception) {
      print(exception);
      print('Access Denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Access Denied\nPlease Allow Access or Enable Access in App Settings')));
    } finally {
      setState(() => loading = false);
    }
  }
}
