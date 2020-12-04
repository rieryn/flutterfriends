import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

FirebaseStorage storage =
    FirebaseStorage.instance;

Future<String> firebasePushImageFile(File imageFile, String hash) async {
  Reference ref = FirebaseStorage.instance.ref().child('images').child(hash);
  UploadTask task = ref.putFile(imageFile);
  String imageURL = 'http://placekitten.com/200/300';
  try{
    TaskSnapshot snapshot = await task;
    imageURL = await snapshot.ref.getDownloadURL();
    return imageURL;
  } on FirebaseException catch (e){
    print (task.snapshot);
  }
  return null;
}
//todo: add permissions for ios
Future<String> pickImageFromGallery() async {
  ImagePicker imagePicker = ImagePicker();
  PickedFile pickedFile;
  File imageFile;
  String imageURL;
  pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
  if (pickedFile !=null){
    imageFile = File(pickedFile.path);
    imageURL = await firebasePushImageFile(imageFile, pickedFile.hashCode.toString());
    return imageURL;
  }
  else{print('no file picked');}
  return null;
}
//todo: add permissions for ios
Future<String> pickImageFromCamera() async {
  ImagePicker imagePicker = ImagePicker();
  PickedFile pickedFile;
  File imageFile;
  String imageURL;
  pickedFile = await imagePicker.getImage(source: ImageSource.camera);
  if (pickedFile !=null){
    imageFile = File(pickedFile.path);
    imageURL = await firebasePushImageFile(imageFile, pickedFile.hashCode.toString());
    return imageURL;
  }
  else{print('no file picked');}
  return null;
}