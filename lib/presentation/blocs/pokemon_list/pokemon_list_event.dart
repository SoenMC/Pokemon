abstract class PokemonListEvent {}
class PokemonRequested extends PokemonListEvent {}
class PokemonLoadMore extends PokemonListEvent {}
class PokemonRefreshed extends PokemonListEvent {}