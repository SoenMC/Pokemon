import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/pokemon_list/pokemon_list_bloc.dart';
import '../blocs/pokemon_list/pokemon_list_event.dart';
import '../blocs/pokemon_list/pokemon_list_state.dart';
import '../cubits/search_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PokemonListBloc>().add(PokemonRequested());
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
        context.read<PokemonListBloc>().add(PokemonLoadMore());
      }
    });
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // 👇 NUEVO: bottom sheet para mostrar el resultado de la búsqueda online
  void _openSearchResultSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchLoading() => const SizedBox(
                height: 160, child: Center(child: CircularProgressIndicator())),
              SearchFound(:final pokemon) => ListTile(
                leading: Image.network(pokemon.imageUrl, width: 56, height: 56),
                title: Text('#${pokemon.id} ${pokemon.name.toUpperCase()}'),
                subtitle: Text([
                  if (pokemon.height != null) 'H: ${(pokemon.height!/10).toStringAsFixed(1)} m',
                  if (pokemon.weight != null) 'W: ${(pokemon.weight!/10).toStringAsFixed(1)} kg',
                ].join('   ')),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/detail/${pokemon.id}');
                },
              ),
              SearchNotFound(:final query) => SizedBox(
                height: 160, child: Center(child: Text('No results for "$query"'))),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search by name or id',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            context.read<SearchCubit>().search(_searchCtrl.text);
            _openSearchResultSheet(context);
          },
        ),
        actions: [
          //botón que dispara búsqueda online
          IconButton(
            tooltip: 'Search online',
            icon: const Icon(Icons.search),
            onPressed: () {
              context.read<SearchCubit>().search(_searchCtrl.text);
              _openSearchResultSheet(context);
            },
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchCtrl.clear();
              context.read<SearchCubit>().reset(); // limpia estado del buscador online
              setState(() {}); // refresca filtro local
            },
          ),
        ],
      ),
      body: BlocBuilder<PokemonListBloc, PokemonListState>(
        builder: (context, state) {
          // Filtro local mientras escribes
          final q = _searchCtrl.text.trim().toLowerCase();
          final filtered = q.isEmpty
              ? state.items
              : state.items.where((p) => p.name.contains(q)).toList();

          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error!),
                  ElevatedButton(
                    onPressed: () => context.read<PokemonListBloc>().add(PokemonRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<PokemonListBloc>().add(PokemonRefreshed()),
            child: ListView.builder(
              controller: _controller,
              itemCount: filtered.length + (state.canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filtered.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final p = filtered[index];
                return ListTile(
                  leading: Image.network(p.imageUrl, width: 56, height: 56),
                  title: Text('#${p.id} ${p.name}'),
                  onTap: () => context.push('/detail/${p.id}'),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.favorite), label: 'Favs'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Sight'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (i) {
          switch (i) {
            case 1: context.push('/favorites'); break;
            case 2: context.push('/sightings'); break;
            case 3: context.push('/settings'); break;
            default: context.go('/'); break;
          }
        },
        selectedIndex: 0,
      ),
    );
  }
}