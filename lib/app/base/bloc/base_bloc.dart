import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/bloc/base_event.dart';

abstract class BaseBloc<E extends BaseEvent, S extends BaseBlocState>
    extends Bloc<E, S> {
  BaseBloc({@required S state}) : super(state);
  void fetchData({bool refresh = false, String listName});
}
