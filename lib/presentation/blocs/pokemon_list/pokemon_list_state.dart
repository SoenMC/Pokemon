import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

class PokemonListState extends Equatable {
  final List<Pokemon> items;
  final bool isLoading;
  final bool canLoadMore;
  final String? error;

  const PokemonListState({
    this.items = const [],
    this.isLoading = false,
    this.canLoadMore = true,
    this.error,
  });

  PokemonListState copyWith({
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
  List<Object?> get props => [items, isLoading, canLoadMore, error];
}