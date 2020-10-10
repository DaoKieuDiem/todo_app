import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/screen/splash_scren/splash_screen.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/common/foundation.dart';
import 'package:todo_app/common/utils/database_utils.dart';
import 'package:todo_app/data/models/task_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtils.initDatabase();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox(HiveBoxName.tasks);
  await Hive.openBox(HiveBoxName.taskList);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState
    extends BaseLayoutState<MyApp, HomeScreenBloc, BaseBlocState> {
  _MyAppState() {
    bloc = HomeScreenBloc()..taskBloc.fetchData(listName: 'My Task');
  }
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  bool get isContentLayout => true;
  @override
  Widget buildContent(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: isIos
          ? CupertinoApp(
              theme: const CupertinoThemeData(),
              home: SplashScreen(),
            )
          : MaterialApp(
              home: SplashScreen(),
            ),
    );
  }
}
