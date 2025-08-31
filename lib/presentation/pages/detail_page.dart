import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../blocs/pokemon_detail/pokemon_detail_cubit.dart';
import '../cubits/favorites_cubit.dart';

class DetailPage extends StatelessWidget {
  final int id;
  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => PokemonDetailCubit(c.read<PokemonRepository>())..load(id),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pokémon #$id'),
          actions: [
            // Toggle favorito desde detalle
            BlocBuilder<FavoritesCubit, Set<int>>(
              builder: (context, favs) {
                final isFav = favs.contains(id);
                return IconButton(
                  tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () => context.read<FavoritesCubit>().toggle(id),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PokemonDetailCubit, PokemonDetailState>(
          builder: (context, state) {
            switch (state) {
              case PokemonDetailLoading():
                return const Center(child: CircularProgressIndicator());
              case PokemonDetailError(:final message):
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:  CrossAxisAlignment.center,
                    children: [
                      Text(message),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.read<PokemonDetailCubit>().load(id),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              case PokemonDetailLoaded(:final data):
                final h = data.height; // decimetres
                final w = data.weight; // hectograms
                final heightMeters = h != null ? (h / 10).toStringAsFixed(1) : '-';
                final weightKg = w != null ? (w / 10).toStringAsFixed(1) : '-';
                final types = (data.types ?? []).map((t) => t.toUpperCase()).toList();

              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,  // centra vertical
                      crossAxisAlignment: CrossAxisAlignment.center, // centra horizontal
                      children: [
                        Image.network(data.imageUrl, width: 180, height: 180),
                        const SizedBox(height: 12),
                        Text(
                          data.name.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(label: Text('Height: $heightMeters m')),
                            Chip(label: Text('Weight: $weightKg kg')),
                            if (types.isNotEmpty)
                              ...types.map((t) => Chip(label: Text(t))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}