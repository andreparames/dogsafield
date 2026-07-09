import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/core/database/connectivity_service.dart';

class FakeConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> _result = [ConnectivityResult.wifi];

  void setResult(List<ConnectivityResult> result) {
    _result = result;
  }

  void emit(List<ConnectivityResult> result) {
    _controller.add(result);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _result;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeConnectivity fakeConnectivity;
  late ConnectivityService service;

  setUp(() {
    fakeConnectivity = FakeConnectivity();
    service = ConnectivityService(connectivity: fakeConnectivity);
  });

  group('isOnline', () {
    test('returns true when connectivity is available', () async {
      fakeConnectivity.setResult([ConnectivityResult.wifi]);
      expect(await service.isOnline, true);
    });

    test('returns false when connectivity is none', () async {
      fakeConnectivity.setResult([ConnectivityResult.none]);
      expect(await service.isOnline, false);
    });
  });

  group('onStatusChanged', () {
    test('emits true when connectivity restored', () async {
      fakeConnectivity.setResult([ConnectivityResult.none]);
      final results = <bool>[];
      final sub = service.onStatusChanged.listen(results.add);
      fakeConnectivity.emit([ConnectivityResult.mobile]);
      await Future(() {});
      expect(results, [true]);
      await sub.cancel();
    });

    test('emits false when connectivity lost', () async {
      final results = <bool>[];
      final sub = service.onStatusChanged.listen(results.add);
      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future(() {});
      expect(results, [false]);
      await sub.cancel();
    });
  });
}
