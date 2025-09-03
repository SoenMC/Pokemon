abstract class PokemonListEvent {} //define app actions
class PokemonRequested extends PokemonListEvent {}
class PokemonLoadMore extends PokemonListEvent {}
class PokemonRefreshed extends PokemonListEvent {}