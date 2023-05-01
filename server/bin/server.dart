/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:server/db_util.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:protocol/protocol.dart';
import 'package:protocol/data_tester.dart';

const resetData = false;

class Server {
  var listenPort = 8080;

  DbUtil du = DbUtil();

  static var userContextSessionAttr = 'userContext';

  Server();

  Future<void> run() async {

    await du.checkData();

    // Use any available host or container IP (usually `0.0.0.0`).
    final ip = InternetAddress.anyIPv4;
    var router = Router()
      ..get('/', _rootHandler)
      ..get('/setup', _setupHandler)
      ..get('/test', _testHandler)
      ..post('/api', _apiHandler)
      ..get('/echo/<message>', _echoHandler);

    // Configure a pipeline that logs requests.
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router);

    // For running in containers, we respect the PORT environment variable.
    listenPort = int.parse(Platform.environment['PORT'] ?? '8080');
    final server = await serve(handler, ip, listenPort);

    du.info('Server listening on port ${server.port}');
    print('Server listening on port ${server.port}');
  }

  Future<Response> _setupHandler(Request req) async {
    // Create the html for the response from the Product of your database
    var html = "Setup";
    try {
      ServerConnection conn = HttpServerConnection(Uri(scheme: 'http', host: 'localhost', port: listenPort, path: '/api'));
      var tester = DataTester(conn);
      await tester.checkSetup();
    }
    catch(err, s) {
      du.severe('server error: $err', err, s);
      print(s);
    }

    return Response.ok(html.toString(), headers: {'content-type': 'text/html'});
  }

  Future<Response> _testHandler(Request req) async {
    try {
      ServerConnection conn = HttpServerConnection(Uri(scheme: 'http', host: 'localhost', port: listenPort, path: '/api'));
      var tester = DataTester(conn);
      await tester.checkSetup();
      await tester.performTest();
    }
    catch(err, s) {
      du.severe('server error: $err', err, s);
      print(s);
      return Response.ok('error\n', headers: {'content-type': 'text/html'});
    }
    return Response.ok('test\n', headers: {'content-type': 'text/html'});
  }

  Future<Response> _apiHandler(Request request) async {
    // Create the html for the response from the Product of your database
    String str = await request.readAsString();
    ServerCommand cmd = ServerCommand.fromJson(jsonDecode(str));
    ServerResponse resp = await du.handleApiRequest(cmd);
    var respStr = jsonEncode(resp);
    du.info('received api: ${jsonEncode(cmd)}, resp: $respStr');
    return Response.ok(respStr, headers: {'content-type': 'application/json'});
  }

  Response _rootHandler(Request req) {
    return Response.ok('Hello, World!\n');
  }

  Response _echoHandler(Request request) {
    final message = request.params['message'];
    return Response.ok('$message\n');
  }
}


void main(List<String> args) async {
  if (resetData) {
    final testDir = Directory('.hive');
    if (testDir.existsSync()) {
      log('Cleaning test directory: $testDir');
      await testDir.delete(recursive: true);
    }
  }
  await DbUtil.staticInit();
  var server = Server();
  await server.run();
}
