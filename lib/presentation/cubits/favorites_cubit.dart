import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit() : super(<int>{});

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('fav_ids') ?? [];
    emit(list.map(int.parse).toSet());
  }

  Future<void> toggle(int id) async {
    final copy = {...state};
    if (copy.contains(id)) { copy.remove(id); } else { copy.add(id); }
    emit(copy);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fav_ids', copy.map((e) => e.toString()).toList());
  }
}