import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/history_model.dart';
import '../models/empleado_model.dart';
import 'dart:async';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria';
  final String _historyCollection = 'registro';
  final String _employeesCollection = 'empleados';

  Future<String> _getEmployeeName(String email) async {
    try {
      final employeeQuery = await _db.collection(_employeesCollection).get();
      final lowerCaseEmail = email.toLowerCase();

      for (var doc in employeeQuery.docs) {
        final docEmail = (doc.data()['email'] as String? ?? '').toLowerCase();
        if (docEmail == lowerCaseEmail) {
          return doc.data()['nombre'] ?? email;
        }
      }
    } catch (e) {
      developer.log(
        'Error fetching employee name for email: $email',
        name: 'FirestoreService._getEmployeeName',
        error: e,
      );
    }
    return email;
  }

  Future<Empleado?> getEmployeeByEmail(String email) async {
    try {
      final querySnapshot = await _db.collection(_employeesCollection).get();
      final lowerCaseEmail = email.toLowerCase();

      for (final doc in querySnapshot.docs) {
        final docData = doc.data();
        final docEmail = (docData['email'] as String? ?? '').toLowerCase();

        if (docEmail == lowerCaseEmail) {
          return Empleado.fromMap(docData, doc.id);
        }
      }
    } catch (e, s) {
      developer.log(
        'Error fetching employee by email: $email',
        name: 'FirestoreService.getEmployeeByEmail',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }

  /// Diagnostic tool: Fetches a list of all emails from the 'empleados' collection.
  Future<List<String>> getAllEmployeeEmails() async {
    List<String> emails = [];
    try {
      final querySnapshot = await _db.collection(_employeesCollection).get();
      for (final doc in querySnapshot.docs) {
        final docData = doc.data();
        if (docData.containsKey('email') && docData['email'] != null) {
          emails.add(docData['email'].toString());
        }
      }
      developer.log(
        'Found ${emails.length} emails in the database.',
        name: 'FirestoreService.getAllEmployeeEmails',
      );
    } catch (e, s) {
      developer.log(
        'Error fetching all employee emails for diagnostics.',
        name: 'FirestoreService.getAllEmployeeEmails',
        error: e,
        stackTrace: s,
      );
      return ['Error al leer la base de datos: $e'];
    }
    return emails;
  }


  Future<void> addProduct(Product product) async {
    final enteredByName = await _getEmployeeName(product.enteredBy ?? '');

    final productRef = _db.collection(_productsCollection).doc(product.name);

    final productData = {
      ...product.toFirestore(),
      'ingresadoPor': enteredByName,
    };

    await productRef.set(productData);

    final historyRef = _db.collection(_historyCollection).doc(product.name);
    final historyData = {
      ...productData,
      'fecha_ingreso': product.fechaIngreso ?? FieldValue.serverTimestamp(),
      'fecha_salida': null,
    };

    await historyRef.set(historyData);
  }

  Future<void> deleteProduct(String productName) async {
    await _db.collection(_productsCollection).doc(productName).delete();
    final historyRef = _db.collection(_historyCollection).doc(productName);
    await historyRef.set({'fecha_salida': Timestamp.now()}, SetOptions(merge: true));
  }

  Future<void> clearHistory() async {
    final historyCollection = _db.collection(_historyCollection);
    final snapshot = await historyCollection.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
        .orderBy('fecha_ingreso', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return HistoryEntry.fromFirestore(doc);
        } catch (e, s) {
          developer.log(
            'Failed to parse history entry: ${doc.id}',
            name: 'FirestoreService.getHistoryEntries',
            error: e,
            stackTrace: s,
          );
          return null;
        }
      }).where((entry) => entry != null).cast<HistoryEntry>().toList();
    });
  }

  Future<void> updateProduct(Product product) async {
    final enteredByName = await _getEmployeeName(product.enteredBy ?? '');

    final productRef = _db.collection(_productsCollection).doc(product.name);

    final productData = {
      ...product.toFirestore(),
      'ingresadoPor': enteredByName,
    };

    await productRef.update(productData);

    final historyRef = _db.collection(_historyCollection).doc(product.name);
    await historyRef.set({
      'nombreproducto': product.name,
      'categoria': product.category,
      'stock': product.quantity,
      'precio': product.price,
      'ingresadoPor': enteredByName,
    }, SetOptions(merge: true));
  }

  Future<void> updateStock(String productName, int newQuantity) async {
    final stockData = {'stock': newQuantity};
    await _db.collection(_productsCollection).doc(productName).update(stockData);
    await _db.collection(_historyCollection).doc(productName).set(stockData, SetOptions(merge: true));
  }

  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Product.fromFirestore(doc);
        } catch (e, s) {
          developer.log(
            'Failed to parse product: ${doc.id}',
            name: 'FirestoreService.getProducts',
            error: e,
            stackTrace: s,
          );
          return null;
        }
      }).where((product) => product != null).cast<Product>().toList();
    });
  }

  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductByCode(String code) async {
    final querySnapshot = await _db
        .collection(_productsCollection)
        .where('codigo', isEqualTo: code)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      try {
        return Product.fromFirestore(doc);
      } catch (e, s) {
        developer.log(
          'Failed to parse product from getProductByCode: ${doc.id}',
          name: 'FirestoreService.getProductByCode',
          error: e,
          stackTrace: s,
        );
      }
    }
    return null;
  }

  Future<Product?> getProductByName(String name) async {
    final snapshot = await _db.collection(_productsCollection).doc(name).get();
    if (snapshot.exists) {
      try {
        return Product.fromFirestore(snapshot);
      } catch (e, s) {
        developer.log(
          'Failed to parse product from getProductByName: ${snapshot.id}',
          name: 'FirestoreService.getProductByName',
          error: e,
          stackTrace: s,
        );
      }
    }
    return null;
  }
}
