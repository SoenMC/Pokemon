import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/entities/pokemon.dart';

sealed class SearchState { const SearchState(); }
class SearchIdle extends SearchState { const SearchIdle(); }
class SearchLoading extends SearchState {}
class SearchFound extends SearchState {
  final Pokemon pokemon;
  const SearchFound(this.pokemon);
}
class SearchNotFound extends SearchState {
  final String query;
  const SearchNotFound(this.query);
}
class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final PokemonRepository repo;
  SearchCubit(this.repo) : super(const SearchIdle());

  Future<void> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) { emit(const SearchIdle()); return; }
    emit(SearchLoading());
    try {
      final p = await repo.getDetail(q); // acepta id o nombre
      emit(SearchFound(p));
    } catch (_) {
      emit(SearchNotFound(q));
    }
  }

  void reset() => emit(const SearchIdle());
}