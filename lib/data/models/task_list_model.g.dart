// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskListModelAdapter extends TypeAdapter<TaskListModel> {
  @override
  final int typeId = 1;

  @override
  TaskListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskListModel(
      listName: fields[0] as String,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskListModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.listName)
      ..writeByte(1)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
