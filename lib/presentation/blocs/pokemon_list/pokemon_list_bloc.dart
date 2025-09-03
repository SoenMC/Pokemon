import 'package:flutter_bloc/flutter_bloc.dart';   //handle events and states
import '../../../domain/repositories/pokemon_repository.dart'; //repo that brings pokemon
import 'pokemon_list_event.dart'; //defines events that the UI requests
import 'pokemon_list_state.dart'; //defines the states that the UI displays

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final PokemonRepository repo; //bring data
  int _offset = 0;
  static const _limit = 20; //manage pagination of 20 by 20

  PokemonListBloc(this.repo) : super(const PokemonListState()) { //INITIAL EMPTY STATE
    on<PokemonRequested>(_onRequested);  
    on<PokemonLoadMore>(_onLoadMore);
    on<PokemonRefreshed>(_onRefreshed);
  }

  Future<void> _onRequested(PokemonRequested e, Emitter emit) async { //call the API e=EVENT Emit= emits the state to the UI
    emit(state.copyWith(isLoading: true, error: null)); //before issuing the data, activate the loading and clear the error.
    _offset = 0; //restart page count 
    try {
      final list = await repo.getList(limit: _limit, offset: _offset); //Call the Pokémon, wait for the response and save the list that arrives
      emit(state.copyWith(items: list, isLoading: false, canLoadMore: list.length == _limit)); //Puts the Pokémon in the item state, removes the loading and if it can load more, it does so.
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString())); //changes the loading and shows the error
    }
  }

  Future<void> _onLoadMore(PokemonLoadMore e, Emitter emit) async {
    if (!state.canLoadMore || state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    _offset += _limit;
    try {
      final more = await repo.getList(limit: _limit, offset: _offset);
      emit(state.copyWith(
        items: [...state.items, ...more],
        isLoading: false,
        canLoadMore: more.length == _limit,
      ));
    } catch (err) {
      // If load more fails, it stops loading but does not break the list already displayed.
      emit(state.copyWith(isLoading: false, error: err.toString(), canLoadMore: false));
    }
  }

  Future<void> _onRefreshed(PokemonRefreshed e, Emitter emit) async { //refresh
    add(PokemonRequested());
  }
}