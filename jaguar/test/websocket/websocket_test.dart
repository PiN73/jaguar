library test.jaguar.websocket;

import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:jaguar/jaguar.dart';

void main() {
  group('Websocket', () {
    Jaguar server;
    setUpAll(() async {
      server = Jaguar(port: 10000);
      server.wsEcho('/echo');
      server.wsStream('/stream',
          (ctx, ws) => Stream.fromIterable(["1", "2", "3", "4", "5"]));
      server.wsResponder('/responder', (ctx, ws) => (data) => data + 1);
      await server.serve();
    });

    tearDownAll(() async {
      await server.close();
    });

    test('Echo', () async {
      final WebSocket socket =
          await WebSocket.connect('ws://localhost:10000/echo');
      socket.add('5');
      expect(await socket.first, '5');
      await socket.close();
    });

    test('Stream', () async {
      final WebSocket socket =
          await WebSocket.connect('ws://localhost:10000/stream');
      final data = await socket.toList();
      expect(data, ["1", "2", "3", "4", "5"]);
      await socket.close();
    });

    test('Responder', () async {
      final WebSocket socket =
          await WebSocket.connect('ws://localhost:10000/responder');
      socket.add(json.encode({'id': 1, 'content': 5}));
      expect(json.decode(await socket.first), {'id': 1, 'content': 6});
      await socket.close();
    });
  });
}
