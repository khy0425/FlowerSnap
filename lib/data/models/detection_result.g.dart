// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionResultAdapter extends TypeAdapter<DetectionResult> {
  @override
  final int typeId = 3;

  @override
  DetectionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionResult(
      boundingBox: fields[0] as BoundingBox,
      confidence: fields[1] as double,
      label: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionResult obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.boundingBox)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DetectionResult',
      json,
      ($checkedConvert) {
        final val = DetectionResult(
          boundingBox: $checkedConvert('bounding_box',
              (v) => BoundingBox.fromJson(v as Map<String, dynamic>)),
          confidence:
              $checkedConvert('confidence', (v) => (v as num).toDouble()),
          label: $checkedConvert('label', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'boundingBox': 'bounding_box'},
    );

Map<String, dynamic> _$DetectionResultToJson(DetectionResult instance) =>
    <String, dynamic>{
      'bounding_box': instance.boundingBox.toJson(),
      'confidence': instance.confidence,
      'label': instance.label,
    };
