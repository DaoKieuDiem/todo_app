import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/screen/all_list_screen/all_task_screen.dart';
import 'package:todo_app/app/screen/complete_screen/complete_task_screen.dart';
import 'package:todo_app/app/screen/incomplete_screen/incomplete_task_screen.dart';
import 'package:todo_app/app/screen/list_tasks_screen/add_list_tasks_screen.dart';
import 'package:todo_app/app/screen/list_tasks_screen/rename_list_tasks_screen.dart';
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

  String get listName => bloc?.taskBloc?.state?.currentListTasks;

  List<String> get listTasks => bloc?.taskBloc?.state?.listTasks;

  List<TaskEntity> get completedTasks => bloc?.taskBloc?.state?.completedTasks;

  List<TaskEntity> get uncompletedTasks =>
      bloc?.taskBloc?.state?.uncompletedTasks;

  int get totalTasks {
    return (completedTasks?.length ?? 0) + (uncompletedTasks?.length ?? 0);
  }

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
      backgroundColor: Colors.white,
      elevation: 0.0,
      title: BlocBuilder(
        cubit: bloc?.taskBloc,
        builder: (context, TaskState state) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              listName,
              style:
                  themeData.textTheme.headline5.copyWith(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: themeData.dividerColor,
          height: 1,
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
                bloc?.getCurrentIndex(currentIndex: _controller.index);
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
                    iconData: Icons.event_available_outlined,
                    title: BottomNavigationBarTitle.completedTask,
                    isActive: currentIndex == 2,
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.event_note_outlined,
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
                  bloc?.getCurrentIndex(currentIndex: index);
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
                      iconData: Icons.event_available_outlined,
                      title: BottomNavigationBarTitle.completedTask,
                      isActive: currentIndex == 2,
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.event_note_outlined,
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
          backgroundColor: themeData.primaryColor,
          onPressed: () {
            bloc?.reset();
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
          return BlocBuilder(
              cubit: bloc?.taskBloc,
              builder: (context, TaskState state) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      _buildSectionUser(context),
                      if (listTasks?.isNotEmpty == true)
                        _buildSectionTaskList(context),
                      _buildBottomSheetItemMenu(Icons.add, 'Create new list'),
                    ],
                  ),
                );
              });
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
                if (listName != defaultList)
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RenameListTaskScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      child: Text(
                        'Rename List',
                        style: themeData.textTheme.subtitle1,
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    if (listName != defaultList) {
                      Navigator.pop(context);
                      if (completedTasks?.isEmpty == true &&
                          uncompletedTasks?.isEmpty == true) {
                        bloc?.taskBloc?.deleteList(listName: listName);
                      } else {
                        _showDeleteListAlert();
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0,
                        (listName != defaultList) ? 10.0 : 20.0, 20.0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete List',
                          style: themeData.textTheme.subtitle1.copyWith(
                            color: (listName == defaultList)
                                ? Colors.black.withOpacity(0.5)
                                : Colors.black,
                          ),
                        ),
                        if (listName == defaultList)
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'The Default list can not delete',
                              style: themeData.textTheme.subtitle2.copyWith(
                                color: Colors.black.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteCompleteAlert();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: Text(
                      'Delete all complete tasks',
                      style: themeData.textTheme.subtitle1.copyWith(
                        color: (completedTasks?.isEmpty == true)
                            ? Colors.black.withOpacity(0.5)
                            : Colors.black,
                      ),
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
                      InkWell(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: FittedBox(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: themeData.dividerColor)),
                            padding: const EdgeInsets.fromLTRB(
                                25.0, 10.0, 20.0, 10.0),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat.yMMMMd('en_US')
                                      .format(selectedDate),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5.0),
                                  child: InkWell(
                                    onTap: () {
                                      bloc?.reset();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 20.0,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              bloc?.taskBloc?.addNewTask(
                                item: TaskEntity(
                                  task: _taskTitleController?.text?.trim(),
                                  detail: _taskDetailController?.text?.trim(),
                                  date: (selectedDate != null)
                                      ? DateFormat('dd-MM-yyyy')
                                          .format(selectedDate)
                                      : null,
                                  listName: listName,
                                ),
                              );
                              _taskTitleController?.clear();
                              _taskDetailController?.clear();
                              bloc?.reset();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Save',
                              style: themeData.textTheme.subtitle1.copyWith(
                                color: _taskTitleController?.value?.text
                                            ?.trim()
                                            ?.isNotEmpty ==
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

  Future<void> _selectDate(BuildContext context) async {
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
          ...listTasks.map((e) => _buildTaskListItem(context, e)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(context, String title) {
    final isActive = listName == title;
    return InkWell(
      onTap: () {
        bloc?.taskBloc?.fetchData(listName: title);
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: (isActive == true)
            ? BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              )
            : const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.fromLTRB(60.0, 20.0, 10.0, 20.0),
        child: Text(
          title,
          style: themeData.textTheme.bodyText2,
        ),
      ),
    );
  }

  Widget _buildBottomSheetItemMenu(IconData icon, String title) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateListTaskScreen(),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }

  void _showDeleteListAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: const Text(
              AlertContentString.deleteListTitle,
            ),
            content: Text(
              '${AlertContentString.deleteListContent} $totalTasks '
              '${(totalTasks == 1) ? 'task' : 'tasks'}',
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AlertContentString.cancel,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  bloc?.taskBloc?.deleteList(listName: listName);
                  Navigator.pop(context);
                },
                child: Text(
                  AlertContentString.delete,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showDeleteCompleteAlert() {
    showDialog(
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
            content: const Text(
              '${AlertContentString.deleteTasksContent} ',
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AlertContentString.cancel,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (completedTasks?.isNotEmpty == true) {
                    bloc?.taskBloc?.deleteAllTask(done: true);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  AlertContentString.delete,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
            ],
          );
        });
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
