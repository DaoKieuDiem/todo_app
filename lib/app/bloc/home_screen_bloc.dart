import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_event.dart';
import 'package:todo_app/app/bloc/event/home_screen_event.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';

class HomeScreenBloc extends BaseBloc<BaseEvent, HomeScreenState> {
  HomeScreenBloc()
      : super(
            state: HomeScreenState(
          currentIndex: 1,
          expandDetailField: false,
        ));
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
    yield HomeScreenState(state: state, selectedDate: event.selectedDate);
  }

  Stream<HomeScreenState> _reset(FabClickedEvent event) async* {
    yield HomeScreenState(state: state, expandDetailField: false, reset: true);
  }

  void getCurrentIndex({int currentIndex}) {
    add(TabChangedEvent(currentIndex: currentIndex));
  }

  void expandDetailField({bool isExpand}) {
    add(ExpandDetailEvent(expandDetailField: isExpand));
  }

  void pickDate({DateTime selectedDate}) {
    add(PickDateEvent(selectedDate: selectedDate));
  }

  void reset() {
    add(FabClickedEvent());
  }

  @override
  void fetchData({bool refresh = false, String listName}) {}
}
