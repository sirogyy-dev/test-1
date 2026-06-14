import '../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String userId, String categoryId) {
    return repository.deleteCategory(userId, categoryId);
  }
}
