import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:messmate_app_full/core/network/api_client.dart';

void main() {
  group('ApiClient', () {
    test('GET returns parsed json map', () async {
      ApiClient.setTestClient(
        MockClient((request) async {
          expect(request.method, 'GET');
          return http.Response(
              jsonEncode({
                'success': true,
                'data': {'ok': true}
              }),
              200);
        }),
      );

      final res = await ApiClient.get('/health', requiresAuth: false);
      expect(res['success'], true);
    });

    test('POST sends body and parses response', () async {
      ApiClient.setTestClient(
        MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['name'], 'Test');
          return http.Response(jsonEncode({'message': 'ok'}), 200);
        }),
      );

      final res = await ApiClient.post('/items',
          body: {'name': 'Test'}, requiresAuth: false);
      expect(res['message'], 'ok');
    });

    test('401 triggers unauthorized handler and retries once', () async {
      var unauthorizedCalled = 0;
      var requestCount = 0;
      ApiClient.configure(
        tokenProvider: () async => 'token',
        onUnauthorized: () async {
          unauthorizedCalled++;
          return true;
        },
      );

      ApiClient.setTestClient(
        MockClient((request) async {
          requestCount++;
          if (requestCount == 1) {
            return http.Response(jsonEncode({'message': 'unauthorized'}), 401);
          }
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      final res = await ApiClient.get('/private');
      expect(res['ok'], true);
      expect(unauthorizedCalled, 1);
    });

    test('retries on 500 and then succeeds', () async {
      var count = 0;
      ApiClient.setTestClient(
        MockClient((request) async {
          count++;
          if (count < 2) {
            return http.Response(jsonEncode({'message': 'server error'}), 500);
          }
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      final res = await ApiClient.get('/retry', requiresAuth: false);
      expect(res['ok'], true);
      expect(count, 2);
    });
  });
}
