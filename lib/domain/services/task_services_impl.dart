import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_i.dart';
import 'package:todo_app/data/repositories/task_repository_impl.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/services/task_services_i.dart';

class TaskServices implements ITaskServices {
  final ITaskRepository taskRepository = TaskRepository();
  @override
  Future<List<TaskEntity>> getAllTask(String listName) async {
    final items = await taskRepository.getAllTask(listName);
    return (items.isNotEmpty == true)
        ? items.map((e) => TaskEntity.fromModel(e)).toList()
        : [];
  }

  @override
  Future<List<TaskEntity>> getCompletedTask({String listName}) async {
    final items = await taskRepository.getCompletedTask(listName: listName);
    return (items.isNotEmpty == true)
        ? items.map((e) => TaskEntity.fromModel(e)).toList()
        : [];
  }

  @override
  Future<TaskEntity> getTask(String id) async {
    final item = await taskRepository.getTask(id);
    return TaskEntity.fromModel(item);
  }

  @override
  Future<List<TaskEntity>> getUncompletedTask({String listName}) async {
    final items = await taskRepository.getUncompletedTask(listName: listName);
    return (items.isNotEmpty == true)
        ? items.map((e) => TaskEntity.fromModel(e)).toList()
        : [];
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    await taskRepository.addTask(TaskModel.fromEntity(task));
  }

  @override
  Future<bool> updateTask(TaskEntity task) async {
    final success = await taskRepository.updateTask(TaskModel.fromEntity(task));
    return success;
  }

  @override
  Future<bool> deleteTask(TaskEntity task) async {
    final success = await taskRepository.deleteTask(TaskModel.fromEntity(task));
    return success;
  }

  @override
  Future<bool> deleteAllTask({bool done}) async {
    final _success = await taskRepository.deleteAllTask(done: done);
    return _success;
  }

  @override
  Future<List<String>> getListTasksName() async {
    final _items = await taskRepository.getListTasksName();
    return (_items.isNotEmpty == true) ? _items : [];
  }
}
