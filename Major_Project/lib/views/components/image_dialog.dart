import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_project/services/firebase/firebase_storage.dart';
import 'package:provider/provider.dart';

class ImagePickerDialog {
  static Future<String> getImgUrl(
    //dunno might reuse it
    BuildContext context,
  ) async {
    final value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        String _imgUrl;
        final User _user = Provider.of<User>(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),

              Text("Pick a profile image"),
              FlatButton(
                height: size.height / 20,
                minWidth: size.width / 4,
                child: Text(FlutterI18n.translate(context, "picker.camera")),
                onPressed: () async {
                  _imgUrl = await pickImageFromCamera();
                  Navigator.of(context).pop(_imgUrl);
                },
              ),
              Divider(),
              FlatButton(
                height: size.height / 20,
                minWidth: size.width / 4,
                child: Text(FlutterI18n.translate(context, "picker.gallary")),
                onPressed: () async {
                  _imgUrl = await pickImageFromGallery();
                  Navigator.of(context).pop(_imgUrl);
                },
              ),
              Divider(),
              FlatButton(
                height: size.height / 20,
                minWidth: size.width / 4,
                child: Text(FlutterI18n.translate(context, "Cancel")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
    return value;
  }
}
