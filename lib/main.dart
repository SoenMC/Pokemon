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
  WidgetsFlutterBinding.ensureInitialized(); //inicializar flutter
  await Hive.initFlutter(); //inicializa base de datos local 
  await initLocator(); //inicializa el service locator, para manejar dependencias y acceder al repo
  runApp(const PokeTrackerApp());//arranca la app con el widget principal
}

class PokeTrackerApp extends StatefulWidget { //maneitne el estado interno, cubits de tema y favoritos
  const PokeTrackerApp({super.key});
  @override
  State<PokeTrackerApp> createState() => _PokeTrackerAppState();
}

class _PokeTrackerAppState extends State<PokeTrackerApp> {
  final _themeCubit = ThemeCubit()..load(); //controla el tema y guarda el estado 
  final _favoritesCubit = FavoritesCubit()..load(); //controla los pokemons favoritos y carga los guardados 

  @override
  void dispose() {  //cierra los cubits cuando el widget se destruye para liberar recursos
    _themeCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {//construye el router de la app, para navegacionpor rutas
    final router = buildRouter();
    return MultiRepositoryProvider( //provee repositorios a toda la app
      providers: [
        RepositoryProvider<PokemonRepository>(create: (_) => sl()),
      ],
      child: MultiBlocProvider( //provee cubit y bloc a toda la app
        providers: [
          BlocProvider(create: (c) => PokemonListBloc(c.read<PokemonRepository>())..add(PokemonRequested())),
          BlocProvider.value(value: _themeCubit),
          BlocProvider.value(value: _favoritesCubit),
          BlocProvider(create: (c) => SearchCubit(c.read<PokemonRepository>())), // <- fix del espacio
        ],
        child: BlocBuilder<ThemeCubit, bool>( // escucha el estado del tema y reconstruye toda la app
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