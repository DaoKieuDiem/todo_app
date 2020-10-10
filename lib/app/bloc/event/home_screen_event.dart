import 'package:todo_app/app/base/bloc/base_event.dart';

class HomeScreenEvent extends BaseEvent {}

class TabChangedEvent extends BaseEvent {
  final int currentIndex;
  TabChangedEvent({this.currentIndex});
}

class PickDateEvent extends BaseEvent {
  final DateTime selectedDate;
  PickDateEvent({this.selectedDate});
}

class ExpandDetailEvent extends BaseEvent {
  final bool expandDetailField;
  ExpandDetailEvent({this.expandDetailField});
}

class FabClickedEvent extends BaseEvent {
  FabClickedEvent();
}
