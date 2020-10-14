import 'package:todo_app/data/models/task_model.dart';

abstract class ITaskRepository {
  Future<TaskModel> getTask(String id);
  Future<List<TaskModel>> getAllTask(String listName);
  Future<List<String>> getListTasksName();
  Future<List<TaskModel>> getCompletedTask({String listName});
  Future<List<TaskModel>> getUncompletedTask({String listName});
  Future<bool> updateTask(TaskModel task);
  Future<bool> addTask(TaskModel task);
  Future<bool> deleteTask(TaskModel task);
  Future<bool> deleteAllTask({bool done});
}
