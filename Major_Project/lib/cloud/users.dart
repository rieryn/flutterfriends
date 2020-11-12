import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/navigation_controller.dart';

class UserNames {
  String username;
  String password;

  UserNames({
    this.username,
    this.password,
  });

  getUserName(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  DocumentReference reference;

  UserNames.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['username'];
    this.password = map['password'];
  }
  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'password': this.password,
    };
  }
}
