import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/state/base_state.dart';

abstract class BaseLayoutState<
    Sf extends StatefulWidget,
    B extends BaseBloc<dynamic, BS>,
    BS extends BaseBlocState> extends BaseState {
  B bloc;
  BS get state => bloc?.state;

  bool get isContentLayout => false;

  @override
  Widget build(BuildContext context) => buildBase(context);

  Widget buildBase(BuildContext context) {
    Widget _body;
    _body = (bloc != null)
        ? BlocBuilder(
            cubit: bloc,
            builder: (context, BS state) {
              if (state?.isLoading == true) {
                return buildLoading(context);
              }
              return buildContent(context);
            },
          )
        : buildContent(context);
    return isContentLayout == true
        ? _body
        : SafeArea(
            child: Scaffold(
              appBar: buildAppBar(context),
              body: _body,
            ),
          );
  }

  Widget buildContent(BuildContext context) => Container();

  Widget buildAppBar(BuildContext context) => null;

  Widget buildLoading(BuildContext context) => Container(
          child: Center(
              child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).accentColor,
        ),
      )));
  Widget buildContentEmpty(BuildContext context) =>
      Container(child: const Center(child: Text('Seem you have not any task')));
}
