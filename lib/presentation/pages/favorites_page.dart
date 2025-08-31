import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../cubits/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PokemonRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, Set<int>>(
        builder: (context, favs) {
          if (favs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          final ids = favs.toList()..sort(); // ordenaditos

          return ListView.separated(
            itemCount: ids.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final id = ids[i];
              return FutureBuilder(
                future: repo.getDetail(id.toString()),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const ListTile(
                      leading: SizedBox(width: 56, height: 56, child: CircularProgressIndicator()),
                      title: Text('Loading...'),
                    );
                  }
                  final p = snap.data!;
                  return ListTile(
                    leading: Image.network(p.imageUrl, width: 56, height: 56),
                    title: Text('#${p.id} ${p.name.toUpperCase()}'),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.favorite),
                      onPressed: () => context.read<FavoritesCubit>().toggle(id),
                    ),
                    onTap: () => context.push('/detail/${p.id}'),
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