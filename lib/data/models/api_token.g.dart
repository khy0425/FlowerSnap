// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_token.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiTokenAdapter extends TypeAdapter<ApiToken> {
  @override
  final int typeId = 0;

  @override
  ApiToken read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiToken(
      provider: fields[0] as String,
      token: fields[1] as String,
      addedAt: fields[2] as DateTime,
      usageCount: fields[3] as int,
      usageLimit: fields[4] as int?,
      isActive: fields[5] as bool,
      expiresAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApiToken obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.provider)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.addedAt)
      ..writeByte(3)
      ..write(obj.usageCount)
      ..writeByte(4)
      ..write(obj.usageLimit)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiTokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiToken _$ApiTokenFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ApiToken',
      json,
      ($checkedConvert) {
        final val = ApiToken(
          provider: $checkedConvert('provider', (v) => v as String),
          token: $checkedConvert('token', (v) => v as String),
          addedAt:
              $checkedConvert('added_at', (v) => DateTime.parse(v as String)),
          usageCount:
              $checkedConvert('usage_count', (v) => (v as num?)?.toInt() ?? 0),
          usageLimit:
              $checkedConvert('usage_limit', (v) => (v as num?)?.toInt()),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          expiresAt: $checkedConvert('expires_at',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'addedAt': 'added_at',
        'usageCount': 'usage_count',
        'usageLimit': 'usage_limit',
        'isActive': 'is_active',
        'expiresAt': 'expires_at'
      },
    );

Map<String, dynamic> _$ApiTokenToJson(ApiToken instance) => <String, dynamic>{
      'provider': instance.provider,
      'token': instance.token,
      'added_at': instance.addedAt.toIso8601String(),
      'usage_count': instance.usageCount,
      if (instance.usageLimit case final value?) 'usage_limit': value,
      'is_active': instance.isActive,
      if (instance.expiresAt?.toIso8601String() case final value?)
        'expires_at': value,
    };
