import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  // true = dark, false = light
  ThemeCubit() : super(false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isDark') ?? false);
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !state;
    await prefs.setBool('isDark', next);
    emit(next);
  }
}