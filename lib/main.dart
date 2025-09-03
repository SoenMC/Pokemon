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
  WidgetsFlutterBinding.ensureInitialized(); //initialize flutter
  await Hive.initFlutter(); //initializes local database
  await initLocator(); //initializes the service locator, to manage dependencies and access the repo
  runApp(const PokeTrackerApp());//start the app with the main widget
}

class PokeTrackerApp extends StatefulWidget { //maintain internal state, topic cubits and favorites
  const PokeTrackerApp({super.key});
  @override
  State<PokeTrackerApp> createState() => _PokeTrackerAppState();
}

class _PokeTrackerAppState extends State<PokeTrackerApp> {
  final _themeCubit = ThemeCubit()..load(); //controls the theme and saves the state
  final _favoritesCubit = FavoritesCubit()..load(); //control favorite pokemons and load saved ones

  @override
  void dispose() {  //closes the qubits when the widget is destroyed to free up resources
    _themeCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {//Build the app router for route navigation
    final router = buildRouter();
    return MultiRepositoryProvider( //provides repositories to the entire app
      providers: [
        RepositoryProvider<PokemonRepository>(create: (_) => sl()),
      ],
      child: MultiBlocProvider( //provides cubit and bloc to the entire app
        providers: [
          BlocProvider(create: (c) => PokemonListBloc(c.read<PokemonRepository>())..add(PokemonRequested())),
          BlocProvider.value(value: _themeCubit),
          BlocProvider.value(value: _favoritesCubit),
          BlocProvider(create: (c) => SearchCubit(c.read<PokemonRepository>())), // <- fix del espacio
        ],
        child: BlocBuilder<ThemeCubit, bool>( // listen to the status of the issue and rebuild the entire app
          builder: (_, isDark) {
            return MaterialApp.router(
              title: 'PokeTracker',
              debugShowCheckedModeBanner: false,
              theme: ThemeData( // liight
                brightness: Brightness.light,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
              ),
              darkTheme: ThemeData( // dark
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