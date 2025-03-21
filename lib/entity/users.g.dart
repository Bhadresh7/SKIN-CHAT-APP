// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'users.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class UsersAdapter extends TypeAdapter<Users> {
//   @override
//   final int typeId = 1;
//
//   @override
//   Users read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return Users(
//       aadharNo: fields[9] as String,
//       mobileNumber: fields[10] as String,
//       uid: fields[0] as String,
//       username: fields[1] as String,
//       email: fields[2] as String,
//       password: fields[3] as String?,
//       role: fields[5] as String,
//       isGoogle: fields[4] as bool?,
//       isAdmin: fields[6] as bool,
//       canPost: fields[7] as bool,
//       isBlocked: fields[8] as bool,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Users obj) {
//     writer
//       ..writeByte(11)
//       ..writeByte(0)
//       ..write(obj.uid)
//       ..writeByte(1)
//       ..write(obj.username)
//       ..writeByte(2)
//       ..write(obj.email)
//       ..writeByte(3)
//       ..write(obj.password)
//       ..writeByte(4)
//       ..write(obj.isGoogle)
//       ..writeByte(5)
//       ..write(obj.role)
//       ..writeByte(6)
//       ..write(obj.isAdmin)
//       ..writeByte(7)
//       ..write(obj.canPost)
//       ..writeByte(8)
//       ..write(obj.isBlocked)
//       ..writeByte(9)
//       ..write(obj.aadharNo)
//       ..writeByte(10)
//       ..write(obj.mobileNumber);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is UsersAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
