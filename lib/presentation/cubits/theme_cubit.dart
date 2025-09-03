import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> { //app theme
  // true = dark, false = light
  ThemeCubit() : super(false);

  Future<void> load() async { //loads the saved theme when starting the app
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isDark') ?? false);
  }

  Future<void> toggle() async { //change the current theme
    final prefs = await SharedPreferences.getInstance();
    final next = !state; 
    await prefs.setBool('isDark', next);//save the new state
    emit(next); //updates the status of the qubit
  }
}