import 'package:todo_app/domain/entities/task_entity.dart';

abstract class ITaskServices {
  Future<TaskEntity> getTask(String id);
  Future<List<TaskEntity>> getAllTask(String listName);
  Future<List<TaskEntity>> getCompletedTask({String listName});
  Future<List<TaskEntity>> getUncompletedTask({String listName});
  Future<bool> updateTask(TaskEntity task);
  Future<void> addTask(TaskEntity task);
  Future<bool> deleteTask(TaskEntity task);
  Future<bool> deleteAllTask({bool done});
}
