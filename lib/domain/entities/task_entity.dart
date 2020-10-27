import 'package:todo_app/data/models/task_model.dart';

class TaskEntity {
  String id;
  String task;
  String detail;
  DateTime startDate;
  DateTime endDate;
  String time;
  bool done;
  String listName;
  String repeat;
  TaskEntity({
    this.id,
    this.task,
    this.detail,
    this.startDate,
    this.endDate,
    this.time,
    this.done,
    this.listName,
    this.repeat,
  });
  factory TaskEntity.fromModel(TaskModel model) {
    return TaskEntity(
      id: model.id,
      task: model.task,
      detail: model.detail,
      startDate: model.date,
      endDate: model.endDate,
      time: model.time,
      done: model.done,
      listName: model.listName,
      repeat: model.repeat,
    );
  }
}
