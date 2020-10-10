import 'package:todo_app/data/models/task_model.dart';

class TaskEntity {
  String id;
  String task;
  String detail;
  String date;
  String time;
  bool done;
  String listName;
  TaskEntity({
    this.id,
    this.task,
    this.detail,
    this.date,
    this.time,
    this.done,
    this.listName,
  });
  factory TaskEntity.fromModel(TaskModel model) {
    return TaskEntity(
      id: model.id,
      task: model.task,
      detail: model.detail,
      date: model.date,
      time: model.time,
      done: model.done,
      listName: model.listName,
    );
  }
}
