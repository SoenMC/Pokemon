import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

class PokemonListState extends Equatable { //Pokemon List
  final List<Pokemon> items;//data that the list saves
  final bool isLoading; //if loading data
  final bool canLoadMore; //if can load more
  final String? error; //if something went wrong

  const PokemonListState({ //constructor with default values
    this.items = const [], //empty list and more can be loaded
    this.isLoading = false,
    this.canLoadMore = true,
    this.error,
  });

  PokemonListState copyWith({ //create a new state by copying the current one //update immutable states
    List<Pokemon>? items,
    bool? isLoading,
    bool? canLoadMore,
    String? error,
  }) => PokemonListState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    canLoadMore: canLoadMore ?? this.canLoadMore,
    error: error,
  );

  @override
  List<Object?> get props => [items, isLoading, canLoadMore, error]; //data to compare
}