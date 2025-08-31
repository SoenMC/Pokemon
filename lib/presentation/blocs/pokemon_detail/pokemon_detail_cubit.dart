import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pokemon_repository.dart';
import '../../../domain/entities/pokemon.dart';

sealed class PokemonDetailState {
  const PokemonDetailState();
}
class PokemonDetailLoading extends PokemonDetailState {}
class PokemonDetailLoaded extends PokemonDetailState {
  final Pokemon data;
  const PokemonDetailLoaded(this.data);
}
class PokemonDetailError extends PokemonDetailState {
  final String message;
  const PokemonDetailError(this.message);
}

class PokemonDetailCubit extends Cubit<PokemonDetailState> {
  final PokemonRepository repo;
  PokemonDetailCubit(this.repo) : super(PokemonDetailLoading());

  Future<void> load(int id) async {
    try {
      emit(PokemonDetailLoading());
      final p = await repo.getDetail(id.toString());
      emit(PokemonDetailLoaded(p));
    } catch (e) {
      emit(const PokemonDetailError('Failed to load detail'));
    }
  }
}