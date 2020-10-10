import 'package:todo_app/app/base/bloc/base_bloc_state.dart';

class HomeScreenState extends BaseBlocState {
  final int currentIndex;
  final bool expandDetailField;
  final DateTime selectedDate;
  HomeScreenState({
    HomeScreenState state,
    int currentIndex,
    bool isLoading,
    bool expandDetailField,
    DateTime selectedDate,
    bool reset,
  })  : currentIndex = currentIndex ?? state?.currentIndex,
        expandDetailField = expandDetailField ?? state?.expandDetailField,
        selectedDate =
            (reset == true) ? null : (selectedDate ?? state?.selectedDate),
        super(
          isLoading: isLoading ?? state?.isLoading,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        );
}
