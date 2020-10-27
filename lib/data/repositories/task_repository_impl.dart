import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_i.dart';

class TaskRepository implements ITaskRepository {
  final box = Hive.box(HiveBoxName.tasks);
  //final Device _calendarClient = CalendarClient();
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  Calendar calendar = Calendar();
  TaskRepository();
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
  Future<bool> addTask(TaskModel task) async {
    calendar = await _retrieveCalendars();
    try {
      if (task?.date != null || task?.endDate != null) {
        if (await _addEventToCalendar(task, calendar) == true) {
          await box.put(task.id, task);
          return true;
        }
        return false;
      }
      await box.put(task.id, task);
      return true;
    } catch (err) {
      debugPrint('can\'t add new task :${err.toString()}');
      return false;
    }
  }

  @override
  Future<bool> updateTask(TaskModel task) async {
    calendar = await _retrieveCalendars();
    try {
      if (task?.date != null || task?.endDate != null) {
        if (await _addEventToCalendar(task, calendar) == true) {
          await box.put(task.id, task);
          return true;
        }
        return false;
      }
      await box.put(task.id, task);
      return true;
    } catch (err) {
      debugPrint('Can not find task, so update fail: ${err.toString()}');
      return false;
    }
  }

  @override
  Future<bool> deleteTask(TaskModel task) async {
    calendar = await _retrieveCalendars();
    try {
      if (task?.date != null || task?.endDate != null) {
        if (await _deleteEventFromCalendar(task, calendar)) {
          await box.delete(task.id);
          return true;
        }
        return false;
      }
      await box.delete(task.id);
      return true;
    } catch (err) {
      debugPrint('Can not find task, so delete fail:${err.toString()}');
      return false;
    }
  }

  @override
  Future<bool> deleteAllTask({bool done}) async {
    calendar = await _retrieveCalendars();
    List<String> _keys;
    List<bool> _results;
    _keys = [];
    for (final value in box.values) {
      if (value.done == done) {
        _keys.add(value.id);
        try {
          final _result = await _deleteEventFromCalendar(value, calendar);
          _results.add(_result);
        } catch (err) {
          debugPrint('delete event error: ${err.toString()}');
        }
      }
    }
    try {
      if (_results.every((element) => element == true)) {
        await box.deleteAll(_keys);
        return true;
      }
    } catch (err) {
      debugPrint(err.toString());
      return false;
    }
  }

  @override
  Future<List<String>> getListTasksName() async {
    List<String> _result;
    _result = [];
    for (final value in box.values) {
      if (_result.isEmpty == true) {
        _result.add(value.listName);
      } else {
        if (_result.firstWhere((element) => element == value.listName,
                orElse: () => null) ==
            null) {
          _result.add(value.listName);
        }
      }
    }
    return _result;
  }

  Future<Calendar> _retrieveCalendars() async {
    //Retrieve user's calendars from mobile device
    //Request permissions first if they haven't been granted
    Calendar _calendar;
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return null;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      _calendar = calendarsResult?.data?.firstWhere(
          (element) => element.isDefault == true,
          orElse: () => null);
    } catch (e) {
      print(e);
    }
    return _calendar;
  }

  Future<bool> _addEventToCalendar(
      TaskModel taskModel, Calendar calendar) async {
    final eventToCreate = Event(calendar.id)
      ..title = taskModel?.task
      ..description = taskModel?.detail
      ..start = taskModel?.date
      ..end = taskModel?.endDate ?? taskModel?.date
      ..eventId = taskModel?.id;
    try {
      final createEventResult =
          await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);
      if (createEventResult.isSuccess &&
          (createEventResult.data?.isNotEmpty ?? false)) {
        return true;
      }
    } catch (err) {
      debugPrint('error add event to calendar: ${err.toString()}');
    }

    return false;
  }

  Future<bool> _deleteEventFromCalendar(
      TaskModel taskModel, Calendar calendar) async {
    final eventToCreate = Event(calendar.id)..eventId = taskModel?.id;
    final createEventResult = await _deviceCalendarPlugin.deleteEvent(
        calendar.id, eventToCreate.eventId);
    if (createEventResult.isSuccess) {
      return true;
    }
    return false;
  }
}
