import 'dart:async';

mixin FormServiceMixin<T> {
  // Broadcast stream for real-time data updates
  final StreamController<List<T>> _dataController =
      StreamController<List<T>>.broadcast();

  // Expose the stream to the outside world
  Stream<List<T>> get dataStream => _dataController.stream;

  void emitData(List<T> data) {
    if (!_dataController.isClosed) {
      _dataController.add(data);
    }
  }

  //CRUD methods interface
  Future<String> create(T item);
  Future<List<T>> readAll();
  Future<T> update(T item);
  Future<T> delete(T item);

  void dispose() {
    _dataController.close();
  }
}
