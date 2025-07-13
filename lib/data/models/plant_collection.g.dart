// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantCollection _$PlantCollectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PlantCollection',
      json,
      ($checkedConvert) {
        final val = PlantCollection(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          plantIds: $checkedConvert('plantIds',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$PlantCollectionToJson(PlantCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantIds': instance.plantIds,
    };
