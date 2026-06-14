import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories(String userId);
  Future<void> createCategory(String userId, Category category);
  Future<void> updateCategory(String userId, Category category);
  Future<void> deleteCategory(String userId, String categoryId);
}
