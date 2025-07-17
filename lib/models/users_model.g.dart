// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsersModelAdapter extends TypeAdapter<UsersModel> {
  @override
  final int typeId = 0;

  @override
  UsersModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsersModel(
      mobileNumber: fields[10] as String,
      uid: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String?,
      role: fields[5] as String,
      isGoogle: fields[4] as bool?,
      isAdmin: fields[6] as bool,
      canPost: fields[7] as bool,
      isBlocked: fields[8] as bool,
      dob: fields[11] as String,
      createdAt: fields[12] as String?,
      imageUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UsersModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.isGoogle)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.isAdmin)
      ..writeByte(7)
      ..write(obj.canPost)
      ..writeByte(8)
      ..write(obj.isBlocked)
      ..writeByte(10)
      ..write(obj.mobileNumber)
      ..writeByte(11)
      ..write(obj.dob)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsersModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
