// IPOModel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class IPOModel {
  final String id;
  final String stockName;
  final int lot;
  final double price;
  final String openingDate;
  final String closingDate;
  final String remark;
  final String status;

  IPOModel({
    required this.id,
    required this.stockName,
    required this.lot,
    required this.price,
    required this.openingDate,
    required this.closingDate,
    required this.remark,
    required this.status,
  });

  factory IPOModel.fromSnapshot(DocumentSnapshot snapshot) {
    // Convert 'price' field to double
    double price = (snapshot['price'] ?? 0.0).toDouble();

    // Convert 'lot' field to int
    int lot = (snapshot['lot'] ?? 0).toInt();

    // Initialize openingDate and closingDate as empty strings
    String openingDate = '';
    String closingDate = '';

    // Check if 'openingDate' field is a Timestamp
    if (snapshot['openingDate'] != null &&
        snapshot['openingDate'] is Timestamp) {
      Timestamp openingTimestamp = snapshot['openingDate'] as Timestamp;
      openingDate = DateFormat('dd/MM/yyyy').format(openingTimestamp.toDate());
    } else if (snapshot['openingDate'] != null) {
      // If 'openingDate' is not null but not a Timestamp, assume it's a String
      openingDate = snapshot['openingDate'] as String;
    }

    // Check if 'closingDate' field is a Timestamp
    if (snapshot['closingDate'] != null &&
        snapshot['closingDate'] is Timestamp) {
      Timestamp closingTimestamp = snapshot['closingDate'] as Timestamp;
      closingDate = DateFormat('dd/MM/yyyy').format(closingTimestamp.toDate());
    } else if (snapshot['closingDate'] != null) {
      // If 'closingDate' is not null but not a Timestamp, assume it's a String
      closingDate = snapshot['closingDate'] as String;
    }

    return IPOModel(
      id: snapshot.id,
      stockName: snapshot['stockName'],
      lot: lot,
      price: price,
      openingDate: openingDate,
      closingDate: closingDate,
      remark: snapshot['remark'],
      status: snapshot['status'] ?? 'All',
    );
  }
}
