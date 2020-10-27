import 'package:hive/hive.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String task;

  @HiveField(2)
  String detail;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String time;

  @HiveField(5)
  bool done;
  @HiveField(6)
  String listName;
  @HiveField(7)
  DateTime endDate;
  @HiveField(8)
  String repeat;
  TaskModel({
    this.id,
    this.task,
    this.detail,
    this.date,
    this.time,
    this.done,
    this.listName,
    this.endDate,
    this.repeat,
  });
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      task: entity.task,
      detail: entity.detail,
      date: entity.startDate,
      time: entity.time,
      done: entity.done,
      listName: entity.listName,
      endDate: entity.endDate,
      repeat: entity.repeat,
    );
  }
}
