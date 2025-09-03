import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../cubits/favorites_cubit.dart';

// Stateless widget representing the favorites screen
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  // Builds the UI of the favorites page
  @override
  Widget build(BuildContext context) {
    // Access the repository to fetch Pokémon details
    final repo = context.read<PokemonRepository>();

    return Scaffold(
      // App bar with the title "Favorites"
      appBar: AppBar(title: const Text('Favorites')),

      // Body listens to FavoritesCubit for the current set of favorite Pokémon IDs
      body: BlocBuilder<FavoritesCubit, Set<int>>(
        builder: (context, favs) {
          // If no favorites, show a message
          if (favs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          // Convert set to list and sort it
          final ids = favs.toList()..sort();

          // Display the list of favorite Pokémon
          return ListView.separated(
            itemCount: ids.length, // Number of items in the list
            separatorBuilder: (_, __) => const Divider(height: 1), // Divider between items
            itemBuilder: (context, i) {
              final id = ids[i];
              return FutureBuilder(
                // Fetch Pokémon details by ID asynchronously
                future: repo.getDetail(id.toString()),
                builder: (context, snap) {
                  // While loading, show a placeholder
                  if (!snap.hasData) {
                    return const ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator()
                      ),
                      title: Text('Loading...'),
                    );
                  }

                  // Once loaded, display Pokémon info
                  final p = snap.data!;
                  return ListTile(
                    leading: Image.network(p.imageUrl, width: 56, height: 56), // Pokémon image
                    title: Text('#${p.id} ${p.name.toUpperCase()}'), // Pokémon ID and name
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.favorite), // Favorite icon
                      onPressed: () => context.read<FavoritesCubit>().toggle(id), // Remove from favorites
                    ),
                    onTap: () => context.push('/detail/${p.id}'), // Navigate to detail page
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
