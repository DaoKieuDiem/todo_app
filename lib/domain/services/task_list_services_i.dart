import 'package:todo_app/domain/entities/task_list_entity.dart';

abstract class ITaskListServices {
  Future<TaskListEntity> getAllTaskList();
  Future<TaskListEntity> getActivedTaskList();
  Future<TaskListEntity> updateTaskList(TaskListEntity model);
  Future<TaskListEntity> saveTaskList(TaskListEntity model);
}
