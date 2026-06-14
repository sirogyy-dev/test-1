import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createCategory(String userId, Category category) {
    return remoteDataSource.addCategory(userId, category);
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) {
    return remoteDataSource.deleteCategory(userId, categoryId);
  }

  @override
  Future<List<Category>> getCategories(String userId) {
    return remoteDataSource.fetchCategories(userId);
  }

  @override
  Future<void> updateCategory(String userId, Category category) {
    return remoteDataSource.updateCategory(userId, category);
  }
}
