import '../entities/pokemon.dart'; //Pokemonn Import

abstract class PokemonRepository { //abstract class so that all classes comply with the methods declared here
  Future<List<Pokemon>> getList({int limit, int offset}); //query API return the list
  Future<Pokemon> getDetail(String idOrName); //RETURN A POKEMON ACCORDING TO THE ID OR NAME QUERY
}