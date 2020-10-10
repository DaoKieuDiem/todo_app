import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/screen/complete_screen/complete_task_screen.dart';
import 'package:todo_app/app/screen/incomplete_screen/incomplete_task_screen.dart';
import 'file:///D:/FlutterProject/todo_app/lib/app/screen/all_list_screen/all_task_screen.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/common/foundation.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState
    extends BaseLayoutState<HomeScreen, HomeScreenBloc, HomeScreenState> {
  CupertinoTabController _controller;
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDetailController = TextEditingController();
  int get currentIndex => state?.currentIndex;
  DateTime get selectedDate => state?.selectedDate;
  bool get isExpand => state?.expandDetailField;
  ThemeData get themeData => Theme.of(context);
  @override
  HomeScreenBloc get bloc => BlocProvider.of<HomeScreenBloc>(context);

  @override
  void dispose() {
    _controller.dispose();
    _taskTitleController.dispose();
    _taskDetailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(initialIndex: 0);
  }

  List<Widget> tabs = [
    AllTaskScreen(),
    CompletedTaskScreen(),
    UncompletedTaskScreen(),
  ];
  @override
  Widget buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          'My Tasks',
          style: themeData.textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: buildAppBar(context),
          body: BlocBuilder(
            cubit: bloc,
            builder: (context, HomeScreenState state) {
              if (state?.isLoading == true) {
                return buildLoading(context);
              }
              return buildContent(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return isIos
        ? CupertinoTabScaffold(
            resizeToAvoidBottomInset: true,
            controller: _controller,
            tabBar: CupertinoTabBar(
              onTap: (int v) {
                bloc.getCurrentIndex(currentIndex: _controller.index);
              },
              items: [
                BottomNavigationBarItem(
                  label: '',
                  icon: FlatButton(
                    onPressed: () {
                      _settingModalBottomSheet(context);
                    },
                    child: Icon(
                      Icons.dehaze_outlined,
                      color: (currentIndex == 0)
                          ? themeData.primaryColor
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.all_inclusive_rounded,
                    title: BottomNavigationBarTitle.allTasks,
                    isActive: currentIndex == 1,
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.check,
                    title: BottomNavigationBarTitle.completedTask,
                    isActive: currentIndex == 2,
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.check_box_outline_blank_outlined,
                    title: BottomNavigationBarTitle.uncompletedTask,
                    isActive: currentIndex == 3,
                  ),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: FlatButton(
                    onPressed: () {
                      _commandModalBottomSheet(context);
                    },
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: (currentIndex == 4)
                          ? themeData.primaryColor
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            tabBuilder: (context, index) {
              if (index > 0 && index < 4) {
                return tabs[index - 1];
              }
              return tabs[currentIndex];
            },
          )
        : Scaffold(
            body: changeTab(currentIndex),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (int index) {
                  bloc.getCurrentIndex(currentIndex: index);
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: SizedBox(
                      width: 80.0,
                      child: FlatButton(
                        onPressed: () {
                          _settingModalBottomSheet(context);
                        },
                        child: Icon(
                          Icons.dehaze_outlined,
                          color: (currentIndex == 0)
                              ? themeData.primaryColor
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.all_inclusive_rounded,
                      title: BottomNavigationBarTitle.allTasks,
                      isActive: currentIndex == 1,
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.check,
                      title: BottomNavigationBarTitle.completedTask,
                      isActive: currentIndex == 2,
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.check_box_outline_blank_outlined,
                      title: BottomNavigationBarTitle.uncompletedTask,
                      isActive: currentIndex == 3,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: FlatButton(
                      onPressed: () {
                        _commandModalBottomSheet(context);
                      },
                      child: Icon(
                        Icons.more_vert_outlined,
                        color: (currentIndex == 4)
                            ? themeData.primaryColor
                            : Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget changeTab(int index) {
    return Stack(children: [
      (index > 0 && index < 4) ? tabs[index - 1] : tabs[currentIndex],
      Positioned(
        bottom: 30.0,
        right: 30.0,
        child: FloatingActionButton(
          onPressed: () {
            bloc.reset();
            _addNewTaskModalBottomSheet(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }

  BottomNavigationBarItem _buildBottomMenu(
      BuildContext context, MyBottomMenuItem item) {
    return BottomNavigationBarItem(
      icon: Icon(
        item.iconData,
        color: Colors.black.withOpacity(0.5),
      ),
      activeIcon: Icon(
        item.iconData,
        color: themeData.primaryColor,
      ),
      label: item.title,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                title: const Text(
                  AlertContentString.alertTitle,
                ),
                content: const Text(AlertContentString.alertContent),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      AlertContentString.no,
                      style: TextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      AlertContentString.yes,
                      style: TextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            })) ??
        false;
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                _buildSectionUser(context),
                _buildSectionTaskList(context),
                _buildBottomSheetItemMenu(Icons.add, 'Create new list'),
              ],
            ),
          );
        });
  }

  void _commandModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: Text(
                      'Rename List',
                      style: themeData.textTheme.subtitle1,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: Text(
                      'Delete List',
                      style: themeData.textTheme.subtitle1,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    bloc?.taskBloc?.deleteAllTask(done: true);
                    Future.delayed(const Duration(milliseconds: 1000))
                        .whenComplete(() => Navigator.pop(context));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: Text(
                      'Delete all complete tasks',
                      style: themeData.textTheme.subtitle1,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSectionUser(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 18.0,
            child: Image(
              height: 40.0,
              width: 40.0,
              image: AssetImage(ImageAssetUrl.avatarImage),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10.0),
          Text(
            'Diem Dao',
            style: themeData.textTheme.subtitle1,
          )
        ],
      ),
    );
  }

  void _addNewTaskModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return AnimatedPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: BlocBuilder(
              cubit: bloc,
              builder: (context, HomeScreenState state) {
                return Wrap(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                      child: TextField(
                        controller: _taskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'New Task',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 15.0,
                            bottom: 5.0,
                            top: 5.0,
                            right: 15.0,
                          ),
                        ),
                        autofocus: true,
                      ),
                    ),
                    if (isExpand == true)
                      Container(
                        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 8.0),
                        child: TextField(
                          controller: _taskDetailController,
                          decoration: const InputDecoration(
                            hintText: 'Add detail',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15.0,
                              bottom: 5.0,
                              top: 5.0,
                              right: 15.0,
                            ),
                          ),
                          autofocus: true,
                        ),
                      ),
                    if (selectedDate != null)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: themeData.dividerColor)),
                        padding: const EdgeInsets.fromLTRB(25.0, 0, 20.0, 8.0),
                        child: Text(
                          DateFormat('yMd').format(selectedDate),
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 30.0, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  bloc?.expandDetailField(isExpand: true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.notes_outlined,
                                    color: themeData.primaryColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.event_available_outlined,
                                    color: themeData.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              bloc.taskBloc.addNewTask(
                                item: TaskEntity(
                                  task: _taskTitleController.text.trim(),
                                  detail: _taskDetailController.text.trim(),
                                  date: (selectedDate != null)
                                      ? DateFormat('yMd').format(selectedDate)
                                      : null,
                                  listName: 'My Task',
                                ),
                              );
                              _taskTitleController.clear();
                              _taskDetailController.clear();
                              Future.delayed(const Duration(milliseconds: 1000))
                                  .whenComplete(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Text(
                              'Save',
                              style: themeData.textTheme.subtitle1.copyWith(
                                color: _taskTitleController.value.text
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? themeData.primaryColor
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
        });
  }

  _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      bloc?.pickDate(selectedDate: picked);
    }
  }

  Widget _buildSectionTaskList(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor,
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          _buildTaskListItem(context, 'Default'),
          _buildTaskListItem(context, 'My Task'),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(context, String listName) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(60.0, 20.0, 10.0, 20.0),
      child: Text(
        listName,
        style: themeData.textTheme.bodyText2,
      ),
    );
  }

  Widget _buildBottomSheetItemMenu(IconData icon, String title) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: themeData.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10.0),
          Text(
            title,
            style: themeData.textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}

class MyBottomMenuItem {
  IconData iconData;
  String title;
  bool isActive;
  MyBottomMenuItem({
    this.iconData,
    this.title,
    this.isActive,
  });
}
