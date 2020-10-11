import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class AddNewTaskEvent extends BaseEvent {
  final TaskEntity item;
  AddNewTaskEvent({this.item});
}

class UpdateTaskEvent extends BaseEvent {
  final TaskEntity item;
  UpdateTaskEvent({this.item});
}

class DeleteTaskEvent extends BaseEvent {
  final TaskEntity item;
  DeleteTaskEvent({this.item});
}

class CheckboxEvent extends BaseEvent {
  final TaskEntity item;
  CheckboxEvent({this.item});
}

class AllTaskDeleteEvent extends BaseEvent {
  final bool done;
  AllTaskDeleteEvent({this.done});
}

class InitEvent extends BaseEvent {
  InitEvent();
}

class CreateListEvent extends BaseEvent {
  final String listName;
  CreateListEvent({this.listName});
}

class RenameListEvent extends BaseEvent {
  final String prevListName;
  final String newListName;
  RenameListEvent({this.prevListName, this.newListName});
}

class DeleteListEvent extends BaseEvent {
  final String listName;
  DeleteListEvent({this.listName});
}
