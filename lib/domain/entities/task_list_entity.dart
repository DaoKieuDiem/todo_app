import 'package:todo_app/data/models/task_list_model.dart';

class TaskListEntity {
  String listName;
  bool isActive;
  String userName;
  TaskListEntity({this.listName, this.isActive, this.userName});
  factory TaskListEntity.fromModel(TaskListModel model) {
    return TaskListEntity(
      listName: model.listName,
      isActive: model.isActive,
      userName: model.userName,
    );
  }
}
