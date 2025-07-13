// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      notes: fields[2] as String?,
      category: fields[3] as String?,
      account: fields[4] as String?,
      fromAccount: fields[5] as String?,
      toAccount: fields[6] as String?,
      date: fields[7] as DateTime,
      type: fields[8] as TransactionType,
      bankName: fields[9] as String?,
      extractedText: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.account)
      ..writeByte(5)
      ..write(obj.fromAccount)
      ..writeByte(6)
      ..write(obj.toAccount)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.bankName)
      ..writeByte(10)
      ..write(obj.extractedText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
