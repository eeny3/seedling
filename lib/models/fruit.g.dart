// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fruit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FruitAdapter extends TypeAdapter<Fruit> {
  @override
  final int typeId = 0;

  @override
  Fruit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fruit(
      id: fields[0] as String,
      type: fields[1] as String,
      xp: fields[2] as int,
      level: fields[3] as int,
      zest: fields[4] as double,
      durability: fields[5] as int,
      lastHarvest: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Fruit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.xp)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.zest)
      ..writeByte(5)
      ..write(obj.durability)
      ..writeByte(6)
      ..write(obj.lastHarvest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FruitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
