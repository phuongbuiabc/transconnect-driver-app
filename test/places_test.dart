import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/core/network/api_client.dart';
import 'package:transconnect_driver_app/core/session/session_client.dart';
import 'package:transconnect_driver_app/features/places/data/places_repository.dart';
import 'package:transconnect_driver_app/features/places/presentation/controllers/places_controller.dart';
import 'package:transconnect_driver_app/features/places/presentation/screens/places_screen.dart';
import 'package:transconnect_driver_app/shared/widgets/map_actions.dart';
import 'package:transconnect_driver_app/shared/widgets/adaptive_scaffold.dart';
import 'package:transconnect_driver_app/shared/theme/app_theme.dart';
import 'helpers/memory_token_store.dart';

final point = {
  'id': 'point-1',
  'name': 'Bến xe minh họa',
  'addressDetail': 'Địa chỉ công cộng',
  'type': 'BusStation',
  'latitude': 10.8791234,
  'longitude': 106.8145678,
  'version': 7,
};
http.Response page(List<Object?> points) => http.Response(
  jsonEncode({
    'succeeded': true,
    'data': {
      'items': points,
      'pageNumber': 1,
      'pageSize': 20,
      'totalRecords': points.length,
      'totalPages': points.isEmpty ? 0 : 1,
    },
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Future<SessionClient> session(
  Future<http.Response> Function(http.Request) respond,
) async {
  final value = SessionClient(
    transport: ApiClient(
      baseUrl: 'https://example.test',
      client: MockClient(respond),
    ),
    store: MemoryStore()
      ..value = jsonEncode({
        'accountGroup': 'Operator',
        'accessToken': 'fixture',
        'refreshToken': 'fixture',
      }),
    accountGroup: 'Operator',
  );
  await value.restore();
  return value;
}

void main() {
  test('map links preserve exact selected WGS84 coordinates', () {
    const lat = 10.8791234, lon = 106.8145678;
    expect(
      MapLinks.view(lat, lon).queryParameters['query'],
      '10.8791234,106.8145678',
    );
    expect(
      MapLinks.directions(lat, lon).queryParameters['destination'],
      '10.8791234,106.8145678',
    );
    expect(MapLinks.other(lat, lon).scheme, 'geo');
    expect(MapLinks.valid(double.nan, lon), false);
    expect(MapLinks.valid(91, lon), false);
  });
  test('latest query wins and logout discards pending points', () async {
    final pending = Completer<http.Response>();
    final api = await session(
      (request) async => request.url.queryParameters['search'] == 'old'
          ? pending.future
          : page([point]),
    );
    final state = PlacesController(PlacesRepository(api));
    addTearDown(state.dispose);
    addTearDown(api.dispose);
    final old = state.search('old');
    await state.search('new');
    expect(state.items.single.id, 'point-1');
    expect(state.items.single.version, 7);
    await api.clear();
    pending.complete(page([point]));
    await old;
    expect(state.items, isEmpty);
    expect(state.loading, false);
  });
  test('a malformed response is an error rather than no results', () async {
    final api = await session(
      (_) async => http.Response('{"succeeded":true,"data":[]}', 200),
    );
    final state = PlacesController(PlacesRepository(api));
    addTearDown(state.dispose);
    addTearDown(api.dispose);
    await state.search('bến xe');
    expect(state.error, isNotNull);
    expect(state.items, isEmpty);
  });
  for (final width in [360.0, 800.0]) {
    testWidgets('places and detail fit width $width at enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = await session((_) async => page([point]));
      final state = PlacesController(PlacesRepository(api));
      addTearDown(state.dispose);
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: AdaptiveScaffold(
            selectedIndex: 0,
            onSelected: (_) {},
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Địa điểm',
              ),
              NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: PlacesScreen(controller: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byType(width >= 720 ? NavigationRail : NavigationBar),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Bến xe minh họa'));
      await tester.tap(find.text('Bến xe minh họa'));
      await tester.pumpAndSettle();
      expect(find.text('10.8791234, 106.8145678'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
