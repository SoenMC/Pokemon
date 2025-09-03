import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesCubit extends Cubit<Set<int>> { //handle IDs of favorite pokemons
  FavoritesCubit() : super(<int>{});

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance(); //Take the saved data to display it when the app has been restarted
    final list = prefs.getStringList('fav_ids') ?? []; //search the list of fav_ids, and if it doesn't exist we use an empty list
    emit(list.map(int.parse).toSet()); //take the list and convert it to a list of INTs emit=updates the state of the cubit
  }

  Future<void> toggle(int id) async {  //function to mark favorite or unmark
    final copy = {...state}; //creates a copy of the current state
    if (copy.contains(id)) { copy.remove(id); } else { copy.add(id); } //compare if it is already there and remove it and if not add it
    emit(copy); //update the qubit and change the state
    final prefs = await SharedPreferences.getInstance(); //open local notebook to save data
    await prefs.setStringList('fav_ids', copy.map((e) => e.toString()).toList());//converts each int to string, converts it to a list and saves the favorites list
  }
}