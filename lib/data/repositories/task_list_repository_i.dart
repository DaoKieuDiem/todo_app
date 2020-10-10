import 'package:todo_app/data/models/task_list_model.dart';

abstract class ITaskListRepository {
  Future<TaskListModel> getAllTaskList();
  Future<TaskListModel> getActivedTaskList();
  Future<TaskListModel> updateTaskList(TaskListModel model);
  Future<TaskListModel> saveTaskList(TaskListModel model);
}
