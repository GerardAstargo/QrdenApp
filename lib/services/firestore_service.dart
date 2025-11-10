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
  final String _employeesCollectionGroup = 'empleados';

  Future<String> _getEmployeeName(String email) async {
    if (email.isEmpty) return email;
    try {
      final employee = await getEmployeeByEmail(email);
      return employee?.nombre ?? email;
    } catch (e, s) {
      developer.log('Error in _getEmployeeName', name: 'FirestoreService', error: e, stackTrace: s);
      return email;
    }
  }

  Future<Empleado?> getEmployeeByEmail(String email) async {
    try {
      final cleanEmail = email.toLowerCase().trim();
      developer.log('Searching for employee with email: "$cleanEmail" using a collectionGroup query.', name: 'FirestoreService');

      // This is the correct and most efficient query.
      // It requires a manual index to be created in the Firebase Console.
      final querySnapshot = await _db
          .collectionGroup(_employeesCollectionGroup)
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final employeeDoc = querySnapshot.docs.first;
        final docData = employeeDoc.data();
        developer.log('SUCCESS: Match found for "$cleanEmail" at path ${employeeDoc.reference.path}', name: 'FirestoreService');
        return Empleado.fromMap(docData, employeeDoc.id, employeeDoc.reference.path);
      }

      developer.log('FAILURE: No match found for "$cleanEmail" in the collection group.', name: 'FirestoreService');
      return null;
    } catch (e, s) {
      developer.log(
        'Error fetching employee by email. This is EXPECTED if the index has not been created yet. Check the logs for a URL to create the index.',
        name: 'FirestoreService.getEmployeeByEmail',
        error: e,
        stackTrace: s,
      );
      // Re-throw the error so the UI can potentially handle it.
      throw FirebaseException(
        plugin: 'FirestoreService',
        code: 'index-not-found',
        message: 'The required index for querying employees is likely missing. Please check the debug console for a URL to create it.',
      );
    }
  }

  Future<void> updateSecurityPin(String employeePath, String pin) async {
    if (employeePath.isEmpty) {
      throw 'La ruta del empleado está vacía. No se puede actualizar el PIN.';
    }
    try {
      final employeeRef = _db.doc(employeePath);
      await employeeRef.update({'securityPin': pin});
      developer.log('Successfully updated PIN for employee at path $employeePath', name: 'FirestoreService');
    } catch (e, s) {
      developer.log('Error updating security PIN', name: 'FirestoreService.updateSecurityPin', error: e, stackTrace: s);
      throw 'No se pudo actualizar el PIN. Inténtalo de nuevo.';
    }
  }

  // --- Other functions below are mostly for other features and do not need changes ---
  
  Future<List<String>> getAllEmployeeEmails() async {
    // This diagnostic function is not critical for the main flow
    return [];
  }

  Future<void> addProduct(Product product) async {
    final enteredByName = await _getEmployeeName(product.enteredBy ?? '');
    final productRef = _db.collection(_productsCollection).doc(product.name);
    final productData = {...product.toFirestore(), 'ingresadoPor': enteredByName};
    await productRef.set(productData);

    final historyRef = _db.collection(_historyCollection).doc(product.name);
    final historyData = {...productData, 'fecha_salida': null};
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
    return _db.collection(_historyCollection).orderBy('fecha_ingreso', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return HistoryEntry.fromFirestore(doc);
        } catch (e, s) {
          developer.log('Failed to parse history entry: ${doc.id}', name: 'FirestoreService.getHistoryEntries', error: e, stackTrace: s);
          return null;
        }
      }).where((entry) => entry != null).cast<HistoryEntry>().toList();
    });
  }

  Future<void> updateProduct(Product product) async {
    final enteredByName = await _getEmployeeName(product.enteredBy ?? '');
    final productRef = _db.collection(_productsCollection).doc(product.name);
    final productData = {...product.toFirestore(), 'ingresadoPor': enteredByName};
    await productRef.update(productData);

    final historyRef = _db.collection(_historyCollection).doc(product.name);
    await historyRef.set({
      'nombreproducto': product.name,
      'categoria': product.category,
      'stock': product.quantity,
      'precio': product.price,
      'ingresadoPor': enteredByName
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
          developer.log('Failed to parse product: ${doc.id}', name: 'FirestoreService.getProducts', error: e, stackTrace: s);
          return null;
        }
      }).where((product) => product != null).cast<Product>().toList();
    });
  }

  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductByCode(String code) async {
    final querySnapshot = await _db.collection(_productsCollection).where('codigo', isEqualTo: code).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      try {
        return Product.fromFirestore(doc);
      } catch (e, s) {
        developer.log('Failed to parse product from getProductByCode: ${doc.id}', name: 'FirestoreService.getProductByCode', error: e, stackTrace: s);
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
        developer.log('Failed to parse product from getProductByName: ${snapshot.id}', name: 'FirestoreService.getProductByName', error: e, stackTrace: s);
      }
    }
    return null;
  }
}
