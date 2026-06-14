import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    CategoryRemoteDataSourceImpl(FirebaseFirestore.instance),
  );
});

final categoryStateProvider = StateNotifierProvider<CategoryController, CategoryState>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryController(
    getCategoriesUseCase: GetCategoriesUseCase(repository),
    createCategoryUseCase: CreateCategoryUseCase(repository),
    updateCategoryUseCase: UpdateCategoryUseCase(repository),
    deleteCategoryUseCase: DeleteCategoryUseCase(repository),
    auth: FirebaseAuth.instance,
  );
});

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

class CategoryState {
  final bool isLoading;
  final List<Category> categories;
  final String? errorMessage;

  const CategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.errorMessage,
  });

  CategoryState copyWith({
    bool? isLoading,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

class CategoryController extends StateNotifier<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final FirebaseAuth auth;

  CategoryController({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.auth,
  }) : super(const CategoryState());

  Future<void> loadCategories() async {
    final user = auth.currentUser;
    if (user == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final categories = await getCategoriesUseCase(user.uid);
    state = state.copyWith(isLoading: false, categories: categories);
  }

  Future<void> createCategory(String name, String color) async {
    final user = auth.currentUser;
    if (user == null) return;

    final category = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    );

    state = state.copyWith(isLoading: true);
    await createCategoryUseCase(user.uid, category);
    await loadCategories();
  }

  Future<void> updateCategory(String categoryId, String name, String color) async {
    final user = auth.currentUser;
    if (user == null) return;

    final existingCategory = state.categories.firstWhere((item) => item.id == categoryId);
    final updatedCategory = Category(
      id: existingCategory.id,
      name: name,
      color: color,
    );

    state = state.copyWith(isLoading: true);
    await updateCategoryUseCase(user.uid, updatedCategory);
    await loadCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    await deleteCategoryUseCase(user.uid, categoryId);
    await loadCategories();
  }
}
