// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisResultAdapter extends TypeAdapter<AnalysisResult> {
  @override
  final int typeId = 1;

  @override
  AnalysisResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisResult(
      id: fields[0] as String,
      name: fields[1] as String,
      scientificName: fields[2] as String,
      confidence: fields[3] as double,
      description: fields[4] as String,
      alternativeNames: (fields[5] as List).cast<String>(),
      imageUrl: fields[6] as String,
      analyzedAt: fields[7] as DateTime,
      apiProvider: fields[8] as String,
      isPremiumResult: fields[9] as bool,
      category: fields[10] as String,
      rarity: fields[11] as int,
      additionalInfo: (fields[12] as Map?)?.cast<String, dynamic>(),
      detectionResults: (fields[13] as List).cast<DetectionResult>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisResult obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.scientificName)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.alternativeNames)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.analyzedAt)
      ..writeByte(8)
      ..write(obj.apiProvider)
      ..writeByte(9)
      ..write(obj.isPremiumResult)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.rarity)
      ..writeByte(12)
      ..write(obj.additionalInfo)
      ..writeByte(13)
      ..write(obj.detectionResults);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AnalysisResult',
      json,
      ($checkedConvert) {
        final val = AnalysisResult(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          scientificName:
              $checkedConvert('scientific_name', (v) => v as String),
          confidence:
              $checkedConvert('confidence', (v) => (v as num).toDouble()),
          description: $checkedConvert('description', (v) => v as String),
          alternativeNames: $checkedConvert('alternative_names',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          imageUrl: $checkedConvert('image_url', (v) => v as String),
          analyzedAt: $checkedConvert(
              'analyzed_at', (v) => DateTime.parse(v as String)),
          apiProvider: $checkedConvert('api_provider', (v) => v as String),
          isPremiumResult:
              $checkedConvert('is_premium_result', (v) => v as bool),
          category: $checkedConvert('category', (v) => v as String),
          rarity: $checkedConvert('rarity', (v) => (v as num?)?.toInt() ?? 1),
          additionalInfo: $checkedConvert(
              'additional_info', (v) => v as Map<String, dynamic>?),
          detectionResults: $checkedConvert(
              'detection_results',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          DetectionResult.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const <DetectionResult>[]),
        );
        return val;
      },
      fieldKeyMap: const {
        'scientificName': 'scientific_name',
        'alternativeNames': 'alternative_names',
        'imageUrl': 'image_url',
        'analyzedAt': 'analyzed_at',
        'apiProvider': 'api_provider',
        'isPremiumResult': 'is_premium_result',
        'additionalInfo': 'additional_info',
        'detectionResults': 'detection_results'
      },
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scientific_name': instance.scientificName,
      'confidence': instance.confidence,
      'description': instance.description,
      'alternative_names': instance.alternativeNames,
      'image_url': instance.imageUrl,
      'analyzed_at': instance.analyzedAt.toIso8601String(),
      'api_provider': instance.apiProvider,
      'is_premium_result': instance.isPremiumResult,
      'category': instance.category,
      'rarity': instance.rarity,
      if (instance.additionalInfo case final value?) 'additional_info': value,
      'detection_results':
          instance.detectionResults.map((e) => e.toJson()).toList(),
    };
