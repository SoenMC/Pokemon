import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<List<Pokemon>> getList({int limit, int offset});
  Future<Pokemon> getDetail(String idOrName);
}