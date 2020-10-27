import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/app/screen/edit_task_screen/edit_task_screen.dart';
import 'package:todo_app/common/color_constant.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/common/utils/app_utils.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class AllTaskScreen extends StatefulWidget {
  @override
  _AllTaskScreenState createState() => _AllTaskScreenState();
}

class _AllTaskScreenState
    extends BaseLayoutState<AllTaskScreen, TaskBloc, TaskState> {
  final TextEditingController _timeRepeatController =
      TextEditingController(text: '1');

  ThemeData get themeData => Theme.of(context);

  List<TaskEntity> get completedTasks => bloc?.state?.completedTasks;

  List<TaskEntity> get uncompletedTasks => bloc?.state?.uncompletedTasks;

  HomeScreenBloc get homeBloc => BlocProvider.of<HomeScreenBloc>(context);

  DateTime get selectedStartDate => homeBloc?.state?.selectedStartDate;

  DateTime get selectedEndDate => homeBloc?.state?.selectedEndDate;

  @override
  TaskBloc get bloc => homeBloc?.taskBloc;
  DateTime _selectedStartDate;
  DateTime _selectedEndDate;
  DateTime time = DateTime.now();

  @override
  bool get isContentLayout => true;

  @override
  void dispose() {
    _timeRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return (completedTasks?.isNotEmpty == true ||
            uncompletedTasks?.isNotEmpty == true)
        ? BlocListener(
            cubit: bloc,
            listener: (context, TaskState state) {
              if (state?.changeCheckMessage?.isNotEmpty == true) {
                Scaffold.of(context, nullOk: true)?.showSnackBar(
                  SnackBar(
                    content: Text(
                      state?.changeCheckMessage,
                      style: themeData.textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                );
                bloc?.reset();
              }
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  child: const Image(
                    image: AssetImage(ImageAssetUrl.backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                ListView(
                  children: [
                    if (uncompletedTasks?.isNotEmpty == true)
                      ...uncompletedTasks
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 20.0, 20.0, 8.0),
                              child: _buildTaskItem(e),
                            ),
                          )
                          .toList(),
                    if (uncompletedTasks?.isNotEmpty == true)
                      const SizedBox(height: 10.0),
                    if (completedTasks?.isNotEmpty == true)
                      Theme(
                        data: themeData.copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding:
                              const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                          title: Text(
                            'Completed(${completedTasks?.length ?? ''})',
                            style: themeData.textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          children: [
                            ...completedTasks
                                .map(
                                  (e) => Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 8.0),
                                    child: _buildTaskItem(e),
                                  ),
                                )
                                .toList()
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          )
        : buildContentEmpty(context);
  }

  @override
  Widget buildContentEmpty(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: const Image(
            image: AssetImage(ImageAssetUrl.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          //bottom: 10.0,
          left: 100.0,
          right: 100.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'A fresh start',
                  style: themeData.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Anything to add?',
                  style: themeData.textTheme.subtitle1.copyWith(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTaskItem(TaskEntity item) {
    final _check = completedTasks?.firstWhere(
          (element) => element == item,
          orElse: () => null,
        ) !=
        null;
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        bloc?.deleteTask(item: item);
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                margin: const EdgeInsets.only(right: 10.0),
                child: Theme(
                  data: themeData.copyWith(
                    toggleableActiveColor: Colors.white,
                  ),
                  child: Checkbox(
                    checkColor: themeData.primaryColor,
                    value: _check,
                    onChanged: (value) {
                      bloc?.checkDone(item: item);
                    },
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    homeBloc?.reset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(task: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.task,
                          style: themeData.textTheme.subtitle1.copyWith(
                            decoration: (_check == true)
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                        if (item?.detail?.isNotEmpty == true)
                          Text(
                            item?.detail,
                            style: themeData.textTheme.subtitle2.copyWith(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (_check == false && item?.startDate != null)
                          BlocBuilder(
                            cubit: BlocProvider.of<HomeScreenBloc>(context),
                            builder: (context, HomeScreenState state) {
                              return InkWell(
                                onTap: () {
                                  _selectDate(context, item: item);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: themeData.dividerColor,
                                    ),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 5.0, 10.0, 5.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (item?.endDate == null)
                                            ? '${DateFormat.yMMMMd('en_US').format(item?.startDate)},'
                                                '${DateFormat.Hm().format(item?.startDate)}'
                                            : '${DateFormat.yMMMMd('en_US').format(item?.startDate)}'
                                                '-${DateFormat.yMMMMd('en_US').format(item?.endDate)}',
                                        style: themeData.textTheme.bodyText2
                                            .copyWith(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                      if (item?.repeat != null)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 5.0,
                                          ),
                                          child: Icon(
                                            Icons.repeat_outlined,
                                            size: 22.0,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {TaskEntity item}) async {
    final now = DateTime.now();
    await showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfDateRangePicker(
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: themeData.textTheme.bodyText1,
                ),
                headerHeight: 80.0,
                initialSelectedDate: now,
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onSelectionChange,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                    child: Icon(
                      Icons.access_time_outlined,
                      color: themeData.disabledColor,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showSetTimeBottomSheet(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kLightWhiteGrey,
                        ),
                        child: Text(
                          (selectedStartDate != null)
                              ? DateFormat.Hm().format(selectedStartDate)
                              : 'Set Time',
                          style: themeData.textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                      child: Icon(
                        Icons.repeat_outlined,
                        color: themeData.disabledColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showRepeatBottomSheet(context);
                      },
                      child: Text(
                        'Repeat',
                        style: themeData.textTheme.bodyText1.copyWith(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.button,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        item
                          ..startDate = DateTime(
                            _selectedStartDate?.year,
                            _selectedStartDate?.month,
                            _selectedStartDate?.day,
                            selectedStartDate?.hour ?? 00,
                            selectedStartDate?.minute ?? 00,
                          )
                          ..endDate = _selectedEndDate;
                        bloc?.updateTask(item: item);
                        /*final _result = DateTime(
                          _selectedStartDate?.year,
                          _selectedStartDate?.month,
                          _selectedStartDate?.day,
                          selectedStartDate?.hour ?? 00,
                          selectedStartDate?.minute ?? 00,
                        );
                        bloc?.pickDate(
                          selectedEndDate: _selectedEndDate,
                          selectedStartDate: _result,
                        );*/
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: themeData.textTheme.button.copyWith(
                          color: themeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _onSelectionChange(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _selectedStartDate = args.value.startDate;
      _selectedEndDate = args.value.endDate;
    } else if (args.value is DateTime) {
      _selectedStartDate = args.value;
      _selectedEndDate = null;
    }
    var _result = DateTime(
      _selectedStartDate?.year,
      _selectedStartDate?.month,
      _selectedStartDate?.day,
      selectedStartDate?.hour ?? 00,
      selectedStartDate?.minute ?? 00,
    );
    homeBloc?.pickDate(
      selectedStartDate: _result,
      selectedEndDate: _selectedEndDate,
    );
  }

  void _showRepeatBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'Every',
                        style: themeData.textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: kLightWhiteGrey,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      width: 50.0,
                      child: TextField(
                        controller: _timeRepeatController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      padding: const EdgeInsets.only(left: 8.0),
                      decoration: BoxDecoration(
                        color: kLightWhiteGrey,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: homeBloc?.state?.typeRepeat,
                          onChanged: (value) {
                            homeBloc?.chooseTypeRepeat(typeRepeat: value);
                          },
                          items: [
                            DropdownMenuItem(
                              value: TypeRepeat.day,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.day,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.week,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.week,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.month,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.month,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.year,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.year,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...DayRepeat.values.map(_buildDateItem).toList(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Start',
                      style: themeData.textTheme.subtitle2,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10.0),
                        // padding:
                        //    const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kLightWhiteGrey,
                        ),
                        child: TextButton(
                          onPressed: () {
                            _showStartDatePicker(context);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              (selectedStartDate != null)
                                  ? DateFormat.yMMMMd('en_us')
                                      .format(selectedStartDate)
                                  : '${DateFormat.yMMMMd('en_us').format(
                                      DateTime.now(),
                                    )}',
                              style: themeData.textTheme.button.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'First occurrence will be'
                    ' ${DateFormat.yMMMMd('en_us').format(
                      DateTime.now(),
                    )}',
                    style: themeData.textTheme.bodyText2.copyWith(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                // padding:
                //    const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: kLightWhiteGrey,
                ),
                child: TextButton(
                  onPressed: () {
                    _showSetTimeBottomSheet(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (selectedStartDate != null)
                          ? DateFormat.Hm().format(selectedStartDate)
                          : 'Set Time',
                      style: themeData.textTheme.button.copyWith(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        bloc?.reset();
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.button,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        homeBloc?.acceptRepeat(
                          timeRepeat: int.parse(
                            _timeRepeatController.text.trim(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: themeData.textTheme.button.copyWith(
                          color: themeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildDateItem(DayRepeat content) {
    var _isSelected = homeBloc?.state?.dayRepeat == content;
    return Container(
      height: 50.0,
      width: 50.0,
      child: InkWell(
        onTap: () {
          homeBloc?.chooseDayRepeat(dayRepeat: content);
        },
        child: Card(
          elevation: 1.0,
          color:
              (_isSelected == true) ? themeData.primaryColor : kLightWhiteGrey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          //clipBehavior: Clip.antiAlias,
          child: Center(
            child: Text(
              AppUtils.standForDayRepeat(content),
              style: themeData.textTheme.subtitle2.copyWith(
                color: (_isSelected == true) ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStartDatePicker(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfDateRangePicker(
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: themeData.textTheme.bodyText1,
                ),
                headerHeight: 80.0,
                initialSelectedDate: (_selectedStartDate != null)
                    ? _selectedStartDate
                    : DateTime.now(),
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: _onSelectionChange,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.button,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final _result = DateTime(
                          _selectedStartDate?.year ?? selectedStartDate?.year,
                          _selectedStartDate?.month ?? selectedStartDate?.month,
                          _selectedStartDate?.day ?? selectedStartDate?.day,
                          selectedStartDate?.hour,
                          selectedStartDate.minute,
                        );
                        homeBloc?.pickDate(
                          selectedStartDate: _result,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: themeData.textTheme.button.copyWith(
                          color: themeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _showSetTimeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 4,
              margin: const EdgeInsets.only(top: 20.0),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: time,
                onDateTimeChanged: (DateTime value) {
                  time = value;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: themeData.textTheme.button,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final _result = DateTime(
                        selectedStartDate?.year ?? time?.year,
                        selectedStartDate?.month ?? time?.month,
                        selectedStartDate?.day ?? time?.day,
                        time?.hour ?? 00,
                        time?.minute ?? 00,
                      );
                      homeBloc?.pickDate(
                        selectedStartDate: _result,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Done',
                      style: themeData.textTheme.button.copyWith(
                        color: themeData.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
