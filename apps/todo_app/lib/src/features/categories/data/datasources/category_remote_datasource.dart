import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> fetchCategories(String userId);
  Future<void> addCategory(String userId, Category category);
  Future<void> updateCategory(String userId, Category category);
  Future<void> deleteCategory(String userId, String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoryRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _categories(String userId) {
    return firestore.collection('users').doc(userId).collection('categories');
  }

  @override
  Future<void> addCategory(String userId, Category category) async {
    await _categories(userId).doc(category.id).set({
      'name': category.name,
      'color': category.color,
    });
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categories(userId).doc(categoryId).delete();
  }

  @override
  Future<List<Category>> fetchCategories(String userId) async {
    final snapshot = await _categories(userId).orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'] as String? ?? '',
        color: data['color'] as String? ?? '#6200EE',
      );
    }).toList();
  }

  @override
  Future<void> updateCategory(String userId, Category category) async {
    await _categories(userId).doc(category.id).update({
      'name': category.name,
      'color': category.color,
    });
  }
}
