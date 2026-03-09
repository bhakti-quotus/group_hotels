// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingModelAdapter extends TypeAdapter<BookingModel> {
  @override
  final int typeId = 0;

  @override
  BookingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingModel(
      id: fields[0] as String,
      propertyId: fields[1] as String,
      hotelName: fields[2] as String,
      roomTypeCode: fields[3] as String,
      bookingCode: fields[4] as String,
      bookedAt: fields[5] as DateTime,
      checkInDate: fields[6] as DateTime,
      checkOutDate: fields[7] as DateTime,
      guests: (fields[8] as List).cast<Guest>(),
      bookingUserEmail: fields[9] as String,
      bookingUserPhone: fields[10] as String,
      amount: fields[11] as double,
      currencyCode: fields[12] as String,
      bookingStatus: fields[13] as String,
      paymentMethod: fields[14] as String,
      numberOfNights: fields[15] as int,
      requestedRooms: fields[16] as int,
      originalResponse: (fields[17] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookingModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.propertyId)
      ..writeByte(2)
      ..write(obj.hotelName)
      ..writeByte(3)
      ..write(obj.roomTypeCode)
      ..writeByte(4)
      ..write(obj.bookingCode)
      ..writeByte(5)
      ..write(obj.bookedAt)
      ..writeByte(6)
      ..write(obj.checkInDate)
      ..writeByte(7)
      ..write(obj.checkOutDate)
      ..writeByte(8)
      ..write(obj.guests)
      ..writeByte(9)
      ..write(obj.bookingUserEmail)
      ..writeByte(10)
      ..write(obj.bookingUserPhone)
      ..writeByte(11)
      ..write(obj.amount)
      ..writeByte(12)
      ..write(obj.currencyCode)
      ..writeByte(13)
      ..write(obj.bookingStatus)
      ..writeByte(14)
      ..write(obj.paymentMethod)
      ..writeByte(15)
      ..write(obj.numberOfNights)
      ..writeByte(16)
      ..write(obj.requestedRooms)
      ..writeByte(17)
      ..write(obj.originalResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuestAdapter extends TypeAdapter<Guest> {
  @override
  final int typeId = 1;

  @override
  Guest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guest(
      firstName: fields[0] as String,
      lastName: fields[1] as String,
      type: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Guest obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
