import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_i.dart';

class TaskRepository implements ITaskRepository {
  final box = Hive.box(HiveBoxName.tasks);
  TaskRepository() {}
  @override
  Future<List<TaskModel>> getAllTask(String listName) async {
    List<TaskModel> result;
    result = [];
    for (final value in box.values) {
      if (value.listName == listName) {
        result.add(value);
      }
    }
    return result.cast<TaskModel>();
  }

  @override
  Future<List<TaskModel>> getCompletedTask({String listName}) async {
    List<TaskModel> result;
    result = [];
    for (final value in box.values) {
      if (value.done == true && value.listName == listName) {
        result.add(value);
      }
    }
    return result.cast<TaskModel>();
  }

  @override
  Future<TaskModel> getTask(String id) {
    return box.get(id);
  }

  @override
  Future<List<TaskModel>> getUncompletedTask({String listName}) async {
    List<TaskModel> result;
    result = [];
    for (final value in box.values) {
      if (value.done == false && value.listName == listName) {
        result.add(value);
      }
    }
    return result.cast<TaskModel>();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await box.put(task.id, task);
  }

  @override
  Future<bool> updateTask(TaskModel task) async {
    try {
      await box.put(task.id, task);
      return true;
    } catch (err) {
      debugPrint('Can not find task, so update fail');
      return false;
    }
  }

  @override
  Future<bool> deleteTask(TaskModel task) async {
    try {
      await box.delete(task.id);
      return true;
    } catch (err) {
      debugPrint('Can not find task, so delete fail');
      return false;
    }
  }

  @override
  Future<bool> deleteAllTask({bool done}) async {
    List<String> _keys;
    _keys = [];
    for (final value in box.values) {
      if (value.done == done) {
        _keys.add(value.id);
      }
    }
    try {
      await box.deleteAll(_keys);
      return true;
    } catch (err) {
      debugPrint(err.toString());
      return false;
    }
  }
}
