import 'package:cloud_firestore/cloud_firestore.dart';

class QrCodeRecord {
  final String code;
  final Timestamp generatedAt;
  final String imageBase64; // Changed from imageUrl to imageBase64

  QrCodeRecord({
    required this.code,
    required this.generatedAt,
    required this.imageBase64,
  });

  // Updated factory constructor to use imageBase64
  factory QrCodeRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QrCodeRecord(
      code: data['code'] ?? '',
      generatedAt: data['generatedAt'] as Timestamp,
      // Get the imageBase64 string, provide an empty default
      imageBase64: data['imageBase64'] ?? '', 
    );
  }
}
