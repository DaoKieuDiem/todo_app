abstract class BaseEvent {}

class FetchDataEvent extends BaseEvent {
  final bool refresh;
  FetchDataEvent({this.refresh});
}
