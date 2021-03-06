library test.jaguar.intercept.before;

import 'package:http/io_client.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:jaguar_resty/jaguar_resty.dart' as resty;
import 'package:test/test.dart';
import 'package:jaguar/jaguar.dart';

final Random rand = new Random.secure();

void genRandom(Context ctx) {
  ctx.addVariable(rand.nextInt(1000), id: 'randomInt');
}

void doublesRandom(Context ctx) {
  int randomInt = ctx.getVariable<int>(id: 'randomInt');
  ctx.addVariable(randomInt * 2, id: 'doubledRandomInt');
}

void main() {
  resty.globalClient = new http.IOClient();

  group('Custom interceptor:Generated', () {
    Jaguar server;
    setUpAll(() async {
      server = Jaguar(port: 10000);
      server
        ..getJson(
            '/two',
            (Context ctx) => {
                  'Random': ctx.getVariable<int>(id: 'randomInt'),
                  'Doubled': ctx.getVariable<int>(id: 'doubledRandomInt'),
                },
            before: [genRandom, doublesRandom]);
      await server.serve();
    });

    tearDownAll(() async {
      await server.close();
    });

    test(
        'one interceptor',
        () => resty
                .get('http://localhost:10000/two')
                .exact(statusCode: 200, mimeType: 'application/json')
                .decodeJson<Map>()
                .then((Map body) {
              expect(body['Random'] * 2, body['Doubled']);
            }));
  });
}
