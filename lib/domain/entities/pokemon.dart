import 'package:equatable/equatable.dart';

//Create Pokemon and they are different
class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final int? height; 
  final int? weight; 
  final List<String>? types;

  //pokemon constructor
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.height,
    this.weight,
    this.types,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, height, weight, types]; //Data that Equatable will compare
}