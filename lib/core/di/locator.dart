import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../../domain/repositories/pokemon_repository.dart';

final sl = GetIt.instance;

Future<void> initLocator() async {
  // Network client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://pokeapi.co/api/v2',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
          headers: {
          'User-Agent': 'PokeTracker/1.0',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return dio;
  });

  // Datasources
  sl.registerLazySingleton<PokemonRemoteDatasource>(
    () => PokemonRemoteDatasource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(sl()),
  );
}