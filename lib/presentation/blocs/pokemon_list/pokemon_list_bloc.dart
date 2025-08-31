import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pokemon_repository.dart';
import 'pokemon_list_event.dart';
import 'pokemon_list_state.dart';

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final PokemonRepository repo;
  int _offset = 0;
  static const _limit = 20;

  PokemonListBloc(this.repo) : super(const PokemonListState()) {
    on<PokemonRequested>(_onRequested);
    on<PokemonLoadMore>(_onLoadMore);
    on<PokemonRefreshed>(_onRefreshed);
  }

  Future<void> _onRequested(PokemonRequested e, Emitter emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    _offset = 0;
    try {
      final list = await repo.getList(limit: _limit, offset: _offset);
      emit(state.copyWith(items: list, isLoading: false, canLoadMore: list.length == _limit));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString()));
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
      // si falla el load more, deja de cargar pero no rompas la lista ya mostrada
      emit(state.copyWith(isLoading: false, error: err.toString(), canLoadMore: false));
    }
  }

  Future<void> _onRefreshed(PokemonRefreshed e, Emitter emit) async {
    add(PokemonRequested());
  }
}