import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/common/common_constant.dart';

class HomeScreenState extends BaseBlocState {
  final int currentIndex;
  final bool expandDetailField;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;

  final int timeRepeat;
  final TypeRepeat typeRepeat;
  final DayRepeat dayRepeat;
  final bool repeat;
  HomeScreenState({
    HomeScreenState state,
    int currentIndex,
    bool isLoading,
    bool expandDetailField,
    DateTime selectedStartDate,
    DateTime selectedEndDate,
    int timeRepeat,
    TypeRepeat typeRepeat,
    DayRepeat dayRepeat,
    bool reset,
    bool repeat,
  })  : currentIndex = currentIndex ?? state?.currentIndex,
        expandDetailField = expandDetailField ?? state?.expandDetailField,
        selectedStartDate = (reset == true)
            ? null
            : (selectedStartDate ?? state?.selectedStartDate),
        selectedEndDate = (reset == true)
            ? null
            : (selectedEndDate ?? state?.selectedEndDate),
        timeRepeat = timeRepeat ?? state?.timeRepeat,
        typeRepeat = typeRepeat ?? state?.typeRepeat,
        dayRepeat = dayRepeat ?? state?.dayRepeat,
        repeat = repeat ?? state?.repeat,
        super(
          isLoading: isLoading ?? state?.isLoading,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        );
}
