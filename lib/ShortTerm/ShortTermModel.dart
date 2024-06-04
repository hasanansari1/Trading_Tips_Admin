// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class ShortTermModel {
  final String id; // Add the id field
  final String category;
  final String status;
  final String stockName;
  final String cmp;
  final String target;
  final String sl;
  final String remark;
  final Timestamp date;

  ShortTermModel({
    required this.id,
    required this.category,
    required this.status,
    required this.stockName,
    required this.cmp,
    required this.target,
    required this.sl,
    required this.remark,
    required this.date,
  });

  factory ShortTermModel.fromSnapshot(DocumentSnapshot snapshot) {
    Timestamp timestamp;

    // Check if the 'date' field is already a Timestamp
    if (snapshot['date'] is Timestamp) {
      timestamp = snapshot['date'];
    } else if (snapshot['date'] is String) {
      // Convert 'date' String to Timestamp (adjust the conversion logic if needed)
      timestamp = Timestamp.fromDate(DateTime.parse(snapshot['date']));
    } else {
      // Handle other cases or provide a default value
      timestamp = Timestamp.now();
    }

    return ShortTermModel(
      id: snapshot.id,
      category: snapshot['category'],
      status: snapshot['status'],
      stockName: snapshot['stockName'],
      cmp: snapshot['cmp'],
      target: snapshot['target'],
      sl: snapshot['sl'],
      remark: snapshot['remark'],
      date: timestamp,
    );
  }
}
