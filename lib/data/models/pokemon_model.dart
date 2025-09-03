import '../../domain/entities/pokemon.dart';

//Create Pokemon Class
class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.height,
    super.weight,
    super.types,
  });

  factory PokemonModel.fromListItem(Map<String, dynamic> json) { //Create Pokemon list
    final url = json['url'] as String; //Bring Url
    final idStr = url.split('/').where((p) => p.isNotEmpty).last; // SPLIT URL WITH */* AND CALL TE LAST
    final id = int.tryParse(idStr) ?? 0; //String to INT
    return PokemonModel(  //return Pokemon
      id: id,
      name: (json['name'] as String?)?.toLowerCase() ?? 'unknown',
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }

  factory PokemonModel.fromDetail(Map<String, dynamic> json) { //Pokemon Detail
    final id = json['id'] as int; //Bring the Json and convert to INT
    final types = (json['types'] as List?) //create List
            ?.map((t) => t['type']?['name']?.toString() ?? '') // Convert data to dynamic string and if is null return null
            .where((s) => s.isNotEmpty) //
            .cast<String>() //convert to string
            .toList() ?? //create list
        const <String>[]; //Immutable list. Empty and receives only strings.
    
    //create the Pokemon
    return PokemonModel( 
      id: id,
      name: (json['name'] as String?)?.toLowerCase() ?? 'unknown',
      imageUrl: json['sprites']?['front_default'] ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      height: json['height'] as int?,
      weight: json['weight'] as int?, 
      types: types,
    );
  }
}