import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/common/common_constant.dart';

class HomeScreenEvent extends BaseEvent {}

class TabChangedEvent extends BaseEvent {
  final int currentIndex;
  TabChangedEvent({this.currentIndex});
}

class PickDateEvent extends BaseEvent {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  PickDateEvent({this.selectedStartDate, this.selectedEndDate});
}

class ExpandDetailEvent extends BaseEvent {
  final bool expandDetailField;
  ExpandDetailEvent({this.expandDetailField});
}

class FabClickedEvent extends BaseEvent {
  FabClickedEvent();
}

class EnterTimeRepeatEvent extends BaseEvent {
  final int timeRepeat;
  EnterTimeRepeatEvent({this.timeRepeat});
}

class ChooseTypeRepeatEvent extends BaseEvent {
  final TypeRepeat typeRepeat;
  ChooseTypeRepeatEvent({this.typeRepeat});
}

class ChooseDayRepeatEvent extends BaseEvent {
  final DayRepeat dayRepeat;
  ChooseDayRepeatEvent({this.dayRepeat});
}

class AcceptRepeatEvent extends BaseEvent {
  final int timeRepeat;
  AcceptRepeatEvent({this.timeRepeat});
}
