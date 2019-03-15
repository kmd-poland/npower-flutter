class ResultState {}

class ResultLoading extends ResultState {}

class ResultError extends ResultState {}

class ResultEmpty extends ResultState {}

class ResultReady<T> extends ResultState {
  final List<T> items;
  ResultReady(this.items);
}