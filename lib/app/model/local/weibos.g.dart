// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weibos.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeibosAdapter extends TypeAdapter<Weibos> {
  @override
  final int typeId = 1;

  @override
  Weibos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Weibos(
      statuses: (fields[0] as List)?.cast<WeiboLite>(),
      sinceId: fields[1] as int,
      maxId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Weibos obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.statuses)
      ..writeByte(1)
      ..write(obj.sinceId)
      ..writeByte(2)
      ..write(obj.maxId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeibosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}