import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  final bool isLoading;
  final int timeStamp;
  BaseBlocState({this.timeStamp = 1, this.isLoading}) : super();

  @override
  List<Object> get props => [isLoading, timeStamp];
}
