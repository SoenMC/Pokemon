import '../../domain/entities/pokemon.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.height,
    super.weight,
    super.types,
  });

  factory PokemonModel.fromListItem(Map<String, dynamic> json) {
    // item de /pokemon?limit&offset (trae url con el id)
    final url = json['url'] as String;
    final idStr = url.split('/').where((p) => p.isNotEmpty).last;
    final id = int.tryParse(idStr) ?? 0;
    return PokemonModel(
      id: id,
      name: (json['name'] as String?)?.toLowerCase() ?? 'unknown',
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }

  factory PokemonModel.fromDetail(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final types = (json['types'] as List?)
            ?.map((t) => t['type']?['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .cast<String>()
            .toList() ??
        const <String>[];

    return PokemonModel(
      id: id,
      name: (json['name'] as String?)?.toLowerCase() ?? 'unknown',
      imageUrl: json['sprites']?['front_default'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      height: json['height'] as int?, // decimetres
      weight: json['weight'] as int?, // hectograms
      types: types,
    );
  }
}