import '../database/database.dart';
import '../models/models.dart';

class CategoryRepository {
  final CategoryDao _dao;

  CategoryRepository({CategoryDao? dao}) : _dao = dao ?? CategoryDao();

  Future<List<Category>> getAll() => _dao.getAll();

  Future<List<Category>> getByType(TransactionType type) =>
      _dao.getByType(type);

  Future<Category?> getById(String id) => _dao.getById(id);

  Future<void> save(Category category) => _dao.insert(category);

  Future<void> update(Category category) => _dao.update(category);

  Future<void> delete(String id) => _dao.delete(id);
}
