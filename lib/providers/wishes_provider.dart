import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_model.dart';
import '../repositories/wishes_repository.dart';

final wishesRepositoryProvider = Provider((_) => WishesRepository());

final wishesProvider =
    AsyncNotifierProvider<WishesNotifier, List<WishModel>>(WishesNotifier.new);

final wishCategoriesProvider =
    AsyncNotifierProvider<WishCategoriesNotifier, List<String>>(
        WishCategoriesNotifier.new);

class WishesNotifier extends AsyncNotifier<List<WishModel>> {
  late final WishesRepository _repo;

  @override
  Future<List<WishModel>> build() async {
    _repo = ref.read(wishesRepositoryProvider);
    return _repo.loadWishes();
  }

  Future<void> addWish(WishModel wish) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, wish];
    state = AsyncData(updated);
    await _repo.saveWishes(updated);
  }

  Future<void> updateWish(WishModel wish) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((w) => w.id == wish.id ? wish : w).toList();
    state = AsyncData(updated);
    await _repo.saveWishes(updated);
  }

  Future<void> deleteWish(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((w) => w.id != id).toList();
    state = AsyncData(updated);
    await _repo.saveWishes(updated);
  }
}

class WishCategoriesNotifier extends AsyncNotifier<List<String>> {
  late final WishesRepository _repo;

  @override
  Future<List<String>> build() async {
    _repo = ref.read(wishesRepositoryProvider);
    return _repo.loadCategories();
  }

  Future<void> addCategory(String category) async {
    final current = state.valueOrNull ?? [];
    if (current.contains(category)) return;
    final updated = [...current, category];
    state = AsyncData(updated);
    await _repo.saveCategories(updated);
  }
}
