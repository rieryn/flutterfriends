import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/navigation_controller.dart';

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

  User.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['username'];
    this.password = map['password'];
    this.birthday = DateTime.parse(map['birthday']);
  }
  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'password': this.password,
      'birthday': this.birthday.toString(),
    };
  }
}
