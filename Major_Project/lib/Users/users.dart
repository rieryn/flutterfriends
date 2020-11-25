import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/navigation_controller.dart';

//user class to model a new user
class User {
  String username;
  String password;
  DateTime birthday;
  DocumentReference reference;

  User({
    this.username,
    this.password,
    this.birthday,
  });

  //model to use pull data from cloud db
  User.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['username'];
    this.password = map['password'];
    map['bithday'] == null
        ? print('no bday')
        : this.birthday = DateTime.parse(map['birthday']);
  }

  //model to use to save data to the cloud db
  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'password': this.password,
      'birthday': this.birthday.toString(),
    };
  }
}
