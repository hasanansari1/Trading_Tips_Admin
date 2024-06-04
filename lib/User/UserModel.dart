import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? Password;
  final String? UserID;
  final String? Mobile;

  UserModel(
      {this.name,
      this.email,
      this.Password,
      this.UserID,
      this.id,
      this.Mobile});

  factory UserModel.fromJson(DocumentSnapshot json) => UserModel(
        id: json.id,
        email: json['Email'],
        name: json['Name'],
        Password: json['Password'],
        UserID: json['UID'],
        Mobile: json['Mobile'],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "Email": email,
        "Password": Password,
        "UID": UserID,
        "Mobile": Mobile,
      };
}
