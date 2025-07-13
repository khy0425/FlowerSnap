// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bounding_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoundingBoxAdapter extends TypeAdapter<BoundingBox> {
  @override
  final int typeId = 2;

  @override
  BoundingBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoundingBox(
      x: fields[0] as double,
      y: fields[1] as double,
      width: fields[2] as double,
      height: fields[3] as double,
      confidence: fields[4] as double,
      label: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BoundingBox obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y)
      ..writeByte(2)
      ..write(obj.width)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoundingBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BoundingBox',
      json,
      ($checkedConvert) {
        final val = BoundingBox(
          x: $checkedConvert('x', (v) => (v as num).toDouble()),
          y: $checkedConvert('y', (v) => (v as num).toDouble()),
          width: $checkedConvert('width', (v) => (v as num).toDouble()),
          height: $checkedConvert('height', (v) => (v as num).toDouble()),
          confidence:
              $checkedConvert('confidence', (v) => (v as num).toDouble()),
          label: $checkedConvert('label', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$BoundingBoxToJson(BoundingBox instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'confidence': instance.confidence,
      'label': instance.label,
    };
