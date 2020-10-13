import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/app/bloc/event/task_event.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/common/common_constant.dart';
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
            listTasks: const [],
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
    } else if (event is CreateListEvent) {
      yield* _createListTasks(event);
    } else if (event is InitEvent) {
      yield* _init(event);
    } else if (event is RenameListEvent) {
      yield* _renameList(event);
    } else if (event is DeleteListEvent) {
      yield* _deleteList(event);
    } else if (event is MoveTaskToListEvent) {
      yield* _moveTaskTo(event);
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
      _completeTask = await taskServices.getCompletedTask(
          listName: state?.currentListTasks);
      _uncompletedTask = await taskServices.getUncompletedTask(
          listName: state?.currentListTasks);
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
    final _listTask = state?.listTasks;
    yield TaskState(
      state: state,
      completedTasks: _completeTask,
      uncompletedTasks: _uncompletedTask,
      isFetchedData: false,
      listTasks: _listTask,
      currentListTasks: event.listName,
      listTaskToMove: event.listName,
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

  Stream<TaskState> _createListTasks(CreateListEvent event) async* {
    List<String> _listTasks;
    _listTasks = [];
    _listTasks = state?.listTasks;
    if (event.listName.isNotEmpty == true) {
      _listTasks.add(event.listName);
    }
    yield TaskState(
      state: state,
      isFetchedData: false,
      completedTasks: const [],
      uncompletedTasks: const [],
      currentListTasks:
          (event.listName.isNotEmpty == true) ? event.listName : null,
      listTasks: _listTasks,
      listTaskToMove:
          (event.listName.isNotEmpty == true) ? event.listName : null,
    );
  }

  Stream<TaskState> _init(InitEvent event) async* {
    List<String> _items;
    _items = [];
    List<TaskEntity> _completeTasks;
    _completeTasks = [];
    List<TaskEntity> _uncompleteTasks;
    _uncompleteTasks = [];
    _items = await taskServices.getListTasksName();
    if (_items.isEmpty == true) {
      _items.add(defaultList);
    } else {
      if (_items.firstWhere((element) => element == defaultList,
              orElse: () => null) ==
          null) {
        _items.add(defaultList);
      }
      _completeTasks = await taskServices.getCompletedTask(listName: _items[0]);
      _uncompleteTasks =
          await taskServices.getUncompletedTask(listName: _items[0]);
    }
    yield TaskState(
      state: state,
      isFetchedData: true,
      completedTasks: _completeTasks,
      uncompletedTasks: _uncompleteTasks,
      currentListTasks: _items[0],
      listTasks: _items,
      listTaskToMove: _items[0],
    );
  }

  Stream<TaskState> _renameList(RenameListEvent event) async* {
    List<String> _listTasks;
    _listTasks = state?.listTasks;
    final _index =
        _listTasks?.indexWhere((element) => element == event.prevListName);
    if (_index != -1) {
      _listTasks.replaceRange(_index, _index + 1, [event.newListName]);
    }
    final _tasks = await taskServices.getAllTask(event.prevListName);
    for (final task in _tasks) {
      task.listName = event.newListName;
      await taskServices.updateTask(task);
    }
    final _completedTasks =
        await taskServices.getCompletedTask(listName: event.newListName);
    final _uncompleteTasks =
        await taskServices.getUncompletedTask(listName: event.newListName);
    yield TaskState(
      state: state,
      isFetchedData: false,
      completedTasks: _completedTasks,
      uncompletedTasks: _uncompleteTasks,
      currentListTasks: event.newListName,
      listTasks: _listTasks,
      listTaskToMove: event.newListName,
    );
  }

  Stream<TaskState> _deleteList(DeleteListEvent event) async* {
    List<String> _listTask;
    _listTask = [];
    _listTask = state?.listTasks;
    if (state?.completedTasks?.isEmpty == true &&
        state?.uncompletedTasks?.isEmpty == true) {
      final _index =
          _listTask.indexWhere((element) => element == event.listName);
      if (_index != -1) {
        _listTask.removeAt(_index);
      }
    } else {
      final _tasks = await taskServices.getAllTask(event.listName);
      for (final task in _tasks) {
        await taskServices.deleteTask(task);
      }
      _listTask = await taskServices.getListTasksName();
    }
    final _completedTasks =
        await taskServices.getCompletedTask(listName: defaultList);
    final _uncompleteTasks =
        await taskServices.getUncompletedTask(listName: defaultList);
    yield TaskState(
      state: state,
      isFetchedData: false,
      completedTasks:
          (_completedTasks.isNotEmpty == true) ? _completedTasks : [],
      uncompletedTasks:
          (_uncompleteTasks.isNotEmpty == true) ? _uncompleteTasks : [],
      currentListTasks: defaultList,
      listTasks: _listTask,
      listTaskToMove: defaultList,
    );
  }

  Stream<TaskState> _moveTaskTo(MoveTaskToListEvent event) async* {
    yield TaskState(state: state, listTaskToMove: event.listName);
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

  void createListTask({String listName}) {
    add(CreateListEvent(listName: listName));
  }

  void renameList({String prevListName, String newListName}) {
    add(RenameListEvent(prevListName: prevListName, newListName: newListName));
  }

  void deleteList({String listName}) {
    add(DeleteListEvent(listName: listName));
  }

  void init() {
    add(InitEvent());
  }

  void moveTaskTo({String listName}) {
    add(MoveTaskToListEvent(listName: listName));
  }
}
