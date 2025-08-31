import 'package:dio/dio.dart';

class PokemonRemoteDatasource {
  final Dio _dio;
  PokemonRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> fetchPokemonList({int limit = 20, int offset = 0}) async {
    final res = await _dio.get('/pokemon', queryParameters: {'limit': limit, 'offset': offset});
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode} on /pokemon');
  }

  Future<Map<String, dynamic>> fetchPokemonDetail(String idOrName) async {
    final res = await _dio.get('/pokemon/$idOrName');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode} on /pokemon/$idOrName');
  }
}