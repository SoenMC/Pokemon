import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../models/pokemon_model.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDatasource remote;
  PokemonRepositoryImpl(this.remote);

  @override
  Future<List<Pokemon>> getList({int limit = 20, int offset = 0}) async {
    final data = await remote.fetchPokemonList(limit: limit, offset: offset);
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results.map((e) => PokemonModel.fromListItem(e)).toList();
  }

  @override
  Future<Pokemon> getDetail(String idOrName) async {
    final data = await remote.fetchPokemonDetail(idOrName);
    return PokemonModel.fromDetail(data);
  }
}