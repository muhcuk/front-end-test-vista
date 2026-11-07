import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:front_end_test_vista/src/api.dart';
import 'package:front_end_test_vista/src/app_state.dart';
import 'package:front_end_test_vista/src/screens.dart';

void main() {
  testWidgets('shows the empty company state', (WidgetTester tester) async {
    final api = ApiClient(client: _EmptyResponseClient());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(api),
        child: const MaterialApp(home: CompanyListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No companies yet. Add your first one.'), findsOneWidget);
  });
}

class _EmptyResponseClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
