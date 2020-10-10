abstract class BaseEvent {}

class FetchDataEvent extends BaseEvent {
  final bool refresh;
  final String listName;
  FetchDataEvent({this.refresh, this.listName});
}
