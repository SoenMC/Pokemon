import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pokemon_repository.dart';
import '../../../domain/entities/pokemon.dart';

sealed class PokemonDetailState {
  const PokemonDetailState();
}
class PokemonDetailLoading extends PokemonDetailState {} //uploading data from the API
class PokemonDetailLoaded extends PokemonDetailState {   // Reiceived data
  final Pokemon data; 
  const PokemonDetailLoaded(this.data); 
}
class PokemonDetailError extends PokemonDetailState { //show error
  final String message; //Final gonna be String
  const PokemonDetailError(this.message); //changes the status to error and displays the message
}

class PokemonDetailCubit extends Cubit<PokemonDetailState> { //HANDLING PREVIOUSLY CREATED STATES LOADING, LOADED, ERROR
  final PokemonRepository repo; // get API
  PokemonDetailCubit(this.repo) : super(PokemonDetailLoading()); //BUILDER RECEIVES REPO

  Future<void> load(int id) async {
    try {
      emit(PokemonDetailLoading()); //STATUS CHANGES TO LOADING
      final p = await repo.getDetail(id.toString());//ASK THE REPO FOR THE POKEMON DETAILS
      emit(PokemonDetailLoaded(p)); //CHANGE STATUS TO LOADED
    } catch (e) {
      emit(const PokemonDetailError('Failed to load detail')); //CHANGE STATUS TO ERROR
    }
  }
}