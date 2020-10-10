import 'package:hive/hive.dart';
import 'package:todo_app/domain/entities/task_list_entity.dart';
part 'task_list_model.g.dart';

@HiveType(typeId: 1)
class TaskListModel extends HiveObject {
  @HiveField(0)
  String listName;
  @HiveField(1)
  bool isActive;
  @HiveField(2)
  String userName;
  TaskListModel({this.listName, this.isActive, this.userName});
  factory TaskListModel.fromEntity(TaskListEntity entity) {
    return TaskListModel(
      listName: entity.listName,
      isActive: entity.isActive,
      userName: entity.userName,
    );
  }
}
