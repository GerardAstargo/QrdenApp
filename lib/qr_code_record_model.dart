import 'package:cloud_firestore/cloud_firestore.dart';

class QrCodeRecord {
  final String code;
  final Timestamp generatedAt;
  final String imageUrl; // Add imageUrl field

  QrCodeRecord({
    required this.code,
    required this.generatedAt,
    required this.imageUrl,
  });

  // Updated factory constructor to include imageUrl
  factory QrCodeRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QrCodeRecord(
      code: data['code'] ?? '',
      generatedAt: data['generatedAt'] as Timestamp,
      imageUrl: data['imageUrl'] ?? '', // Get the imageUrl, provide a default
    );
  }
}
