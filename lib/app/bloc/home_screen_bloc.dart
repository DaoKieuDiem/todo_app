import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/app/bloc/event/home_screen_event.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/common/common_constant.dart';

class HomeScreenBloc extends BaseBloc<BaseEvent, HomeScreenState> {
  HomeScreenBloc()
      : super(
          state: HomeScreenState(
            currentIndex: 1,
            expandDetailField: false,
            timeRepeat: 1,
            typeRepeat: TypeRepeat.week,
            repeat: false,
          ),
        );
  TaskBloc taskBloc = TaskBloc();
  @override
  Future<void> close() {
    taskBloc.close();
    return super.close();
  }

  @override
  Stream<HomeScreenState> mapEventToState(BaseEvent event) async* {
    if (event is TabChangedEvent) {
      yield* _getCurrentIndex(event);
    } else if (event is ExpandDetailEvent) {
      yield* _expandDetailField(event);
    } else if (event is PickDateEvent) {
      yield* _pickDate(event);
    } else if (event is FabClickedEvent) {
      yield* _reset(event);
    } else if (event is EnterTimeRepeatEvent) {
      yield* _getTimeRepeat(event);
    } else if (event is ChooseTypeRepeatEvent) {
      yield* _chooseTypeRepeat(event);
    } else if (event is ChooseDayRepeatEvent) {
      yield* _chooseDayRepeat(event);
    } else if (event is AcceptRepeatEvent) {
      yield* _acceptRepeat(event);
    }
  }

  Stream<HomeScreenState> _getCurrentIndex(TabChangedEvent event) async* {
    yield HomeScreenState(state: state, currentIndex: event.currentIndex);
  }

  Stream<HomeScreenState> _expandDetailField(ExpandDetailEvent event) async* {
    yield HomeScreenState(
      state: state,
      expandDetailField: event.expandDetailField,
    );
  }

  Stream<HomeScreenState> _pickDate(PickDateEvent event) async* {
    yield HomeScreenState(
      state: state,
      selectedStartDate: event.selectedStartDate,
      selectedEndDate: event.selectedEndDate,
    );
  }

  Stream<HomeScreenState> _reset(FabClickedEvent event) async* {
    yield HomeScreenState(
      state: state,
      expandDetailField: false,
      reset: true,
      timeRepeat: 1,
      typeRepeat: TypeRepeat.week,
      repeat: false,
    );
  }

  Stream<HomeScreenState> _getTimeRepeat(EnterTimeRepeatEvent event) async* {
    yield HomeScreenState(
      state: state,
      timeRepeat: event.timeRepeat,
    );
  }

  Stream<HomeScreenState> _chooseTypeRepeat(
      ChooseTypeRepeatEvent event) async* {
    yield HomeScreenState(
      state: state,
      typeRepeat: event.typeRepeat,
    );
  }

  Stream<HomeScreenState> _chooseDayRepeat(ChooseDayRepeatEvent event) async* {
    yield HomeScreenState(
      state: state,
      dayRepeat: event.dayRepeat,
    );
  }

  Stream<HomeScreenState> _acceptRepeat(AcceptRepeatEvent event) async* {
    yield HomeScreenState(
      state: state,
      repeat: true,
      timeRepeat: event.timeRepeat,
    );
  }

  void getCurrentIndex({int currentIndex}) {
    add(TabChangedEvent(currentIndex: currentIndex));
  }

  void expandDetailField({bool isExpand}) {
    add(ExpandDetailEvent(expandDetailField: isExpand));
  }

  void pickDate({DateTime selectedStartDate, DateTime selectedEndDate}) {
    add(PickDateEvent(
      selectedStartDate: selectedStartDate,
      selectedEndDate: selectedEndDate,
    ));
  }

  void reset() {
    add(FabClickedEvent());
  }

  void getTimeRepeat({int timeRepeat}) {
    add(EnterTimeRepeatEvent(timeRepeat: timeRepeat));
  }

  void chooseTypeRepeat({TypeRepeat typeRepeat}) {
    add(ChooseTypeRepeatEvent(typeRepeat: typeRepeat));
  }

  void chooseDayRepeat({DayRepeat dayRepeat}) {
    add(ChooseDayRepeatEvent(dayRepeat: dayRepeat));
  }

  void acceptRepeat({int timeRepeat}) {
    add(AcceptRepeatEvent(timeRepeat: timeRepeat));
  }

  @override
  void fetchData({bool refresh = false, String listName}) {}
}
