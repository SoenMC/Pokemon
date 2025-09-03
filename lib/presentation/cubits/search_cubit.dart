import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/entities/pokemon.dart';

sealed class SearchState { const SearchState(); }  //base class of all states
class SearchIdle extends SearchState { const SearchIdle(); } //initial state "no search"
class SearchLoading extends SearchState {} //been charging
class SearchFound extends SearchState {//state when a pokemon is found
  final Pokemon pokemon;
  const SearchFound(this.pokemon); //pokemon information
}
class SearchNotFound extends SearchState { //the pokemon was not found
  final String query; //save query
  const SearchNotFound(this.query); //show information to user
}
class SearchError extends SearchState { //state when an error occurs
  final String message;
  const SearchError(this.message); //shows error message
}

class SearchCubit extends Cubit<SearchState> { //controls the state of the search
  final PokemonRepository repo; //takes data from the repo
  SearchCubit(this.repo) : super(const SearchIdle()); //initial state nothing has been found yet

  Future<void> search(String query) async { //search by query
    final q = query.trim().toLowerCase(); //remove spaces at the beginning or end of the search // convert everything to lowercase
    if (q.isEmpty) { emit(const SearchIdle()); return; } //Check if the list is empty and terminate the process if so.
    emit(SearchLoading()); //emits the loading state so that the UI shows that it is searching
    try {
      final p = await repo.getDetail(q); // search for pokemon info, name or ID
      emit(SearchFound(p)); //If the Pokémon is found, it changes state.
    } catch (_) {
      emit(SearchNotFound(q)); //not found and status changes
    }
  }

  void reset() => emit(const SearchIdle()); //resets the state to empty, to clear the search
}