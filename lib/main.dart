import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/locator.dart';
import 'core/routing/app_router.dart';
import 'presentation/blocs/pokemon_list/pokemon_list_bloc.dart';
import 'presentation/blocs/pokemon_list/pokemon_list_event.dart';
import 'presentation/cubits/theme_cubit.dart';
import 'presentation/cubits/favorites_cubit.dart';
import 'domain/repositories/pokemon_repository.dart';
import 'presentation/cubits/search_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initLocator();
  runApp(const PokeTrackerApp());
}

class PokeTrackerApp extends StatefulWidget {
  const PokeTrackerApp({super.key});
  @override
  State<PokeTrackerApp> createState() => _PokeTrackerAppState();
}

class _PokeTrackerAppState extends State<PokeTrackerApp> {
  final _themeCubit = ThemeCubit()..load();
  final _favoritesCubit = FavoritesCubit()..load();

  @override
  void dispose() {
    _themeCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PokemonRepository>(create: (_) => sl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => PokemonListBloc(c.read<PokemonRepository>())..add(PokemonRequested())),
          BlocProvider.value(value: _themeCubit),
          BlocProvider.value(value: _favoritesCubit),
          BlocProvider(create: (c) => SearchCubit(c.read<PokemonRepository>())), // <- fix del espacio
        ],
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (_, isDark) {
            return MaterialApp.router(
              title: 'PokeTracker',
              debugShowCheckedModeBanner: false,
              theme: ThemeData( // claro
                brightness: Brightness.light,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
              ),
              darkTheme: ThemeData( // oscuro
                brightness: Brightness.dark,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
              ),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}