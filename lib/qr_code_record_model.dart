import 'package:cloud_firestore/cloud_firestore.dart';

class QrCodeRecord {
  final String code;
  final Timestamp generatedAt;

  QrCodeRecord({required this.code, required this.generatedAt});

  // Factory constructor to create a QrCodeRecord from a Firestore document
  factory QrCodeRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QrCodeRecord(
      code: data['code'] ?? '',
      generatedAt: data['generatedAt'] as Timestamp,
    );
  }
}
