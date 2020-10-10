import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/app/bloc/event/task_event.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/domain/services/task_services_i.dart';
import 'package:todo_app/domain/services/task_services_impl.dart';

class TaskBloc extends BaseBloc<BaseEvent, TaskState> {
  final ITaskServices taskServices = TaskServices();
  TaskBloc()
      : super(
          state: TaskState(
            completedTasks: const [],
            uncompletedTasks: const [],
            isFetchedData: false,
          ),
        );
  @override
  Stream<TaskState> mapEventToState(BaseEvent event) async* {
    if (event is AddNewTaskEvent) {
      yield* _addNewTask(event);
    } else if (event is UpdateTaskEvent) {
      yield* _updateTask(event);
    } else if (event is DeleteTaskEvent) {
      yield* _deleteTask(event);
    } else if (event is CheckboxEvent) {
      yield* _checkDone(event);
    } else if (event is FetchDataEvent) {
      yield* _fetchData(event);
    } else if (event is AllTaskDeleteEvent) {
      yield* _deleteAllTask(event);
    }
  }

  Stream<TaskState> _addNewTask(AddNewTaskEvent event) async* {
    final allTasks = await taskServices.getAllTask(event.item.listName);
    if (allTasks.isEmpty == true) {
      event.item.id = '0';
    } else {
      event.item.id = '${int.parse(allTasks.last.id.trim()) + 1}';
    }
    event.item.done = false;
    await taskServices.addTask(event.item);
    final items =
        await taskServices.getUncompletedTask(listName: event.item.listName);
    yield TaskState(
      state: state,
      uncompletedTasks: items,
      isFetchedData: false,
    );
  }

  Stream<TaskState> _updateTask(UpdateTaskEvent event) async* {
    var _completeTask = [];
    var _uncompletedTask = [];
    final _success = await taskServices.updateTask(event.item);
    if (_success == true) {
      _completeTask =
          await taskServices.getCompletedTask(listName: event.item.listName);
      _uncompletedTask =
          await taskServices.getUncompletedTask(listName: event.item.listName);
    }
    yield TaskState(
      state: state,
      completedTasks: (_success == true) ? _completeTask : null,
      uncompletedTasks: (_success == true) ? _uncompletedTask : null,
      isFetchedData: false,
    );
  }

  Stream<TaskState> _deleteTask(DeleteTaskEvent event) async* {
    var _completeTask = [];
    var _uncompletedTask = [];
    final _success = await taskServices.deleteTask(event.item);
    if (_success == true) {
      _completeTask =
          await taskServices.getCompletedTask(listName: event.item.listName);
      _uncompletedTask =
          await taskServices.getUncompletedTask(listName: event.item.listName);
    }
    yield TaskState(
      state: state,
      completedTasks: (_success == true) ? _completeTask : null,
      uncompletedTasks: (_success == true) ? _uncompletedTask : null,
      isFetchedData: false,
    );
  }

  Stream<TaskState> _checkDone(CheckboxEvent event) async* {
    event.item.done = !event.item.done;
    var _completeTask = [];
    var _uncompletedTask = [];
    final _success = await taskServices.updateTask(event.item);
    if (_success == true) {
      _completeTask =
          await taskServices.getCompletedTask(listName: event.item.listName);
      _uncompletedTask =
          await taskServices.getUncompletedTask(listName: event.item.listName);
    }
    yield TaskState(
      state: state,
      completedTasks: (_success == true) ? _completeTask : null,
      uncompletedTasks: (_success == true) ? _uncompletedTask : null,
    );
  }

  Stream<TaskState> _fetchData(FetchDataEvent event) async* {
    final _completeTask =
        await taskServices.getCompletedTask(listName: event.listName);
    final _uncompletedTask =
        await taskServices.getUncompletedTask(listName: event.listName);
    yield TaskState(
      state: state,
      completedTasks: _completeTask,
      uncompletedTasks: _uncompletedTask,
      isFetchedData: true,
    );
  }

  Stream<TaskState> _deleteAllTask(AllTaskDeleteEvent event) async* {
    final _success = await taskServices.deleteAllTask(done: event.done);
    yield TaskState(
      state: state,
      isFetchedData: false,
      completedTasks: (_success == true && event.done == true) ? [] : null,
      uncompletedTasks: (_success == true && event.done == false) ? [] : null,
    );
  }

  @override
  void fetchData({bool refresh = false, String listName}) {
    add(FetchDataEvent(refresh: refresh, listName: listName));
  }

  void addNewTask({TaskEntity item}) {
    add(AddNewTaskEvent(item: item));
  }

  void updateTask({TaskEntity item}) {
    add(UpdateTaskEvent(item: item));
  }

  void deleteTask({TaskEntity item}) {
    add(DeleteTaskEvent(item: item));
  }

  void checkDone({TaskEntity item}) {
    add(CheckboxEvent(item: item));
  }

  void deleteAllTask({bool done}) {
    add(AllTaskDeleteEvent(done: done));
  }
}
