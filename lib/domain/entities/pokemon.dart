import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final int? height; // decimetres
  final int? weight; // hectograms
  final List<String>? types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.height,
    this.weight,
    this.types,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, height, weight, types];
}