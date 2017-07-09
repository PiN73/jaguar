// GENERATED CODE - DO NOT MODIFY BY HAND

part of test.jaguar.interceptor.inject_request;

// **************************************************************************
// Generator: ApiGenerator
// Target: class ExampleApi
// **************************************************************************

class JaguarExampleApi implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Get(path: '/echo/uri')
  ];

  final ExampleApi _internal;

  JaguarExampleApi(this._internal);

  Future<Response> handleRequest(Context ctx, {String prefix: ''}) async {
    prefix += '/api';
    bool match = false;

//Handler for getJaguarInfo
    match = routes[0].match(ctx.path, ctx.method, prefix, ctx.pathParams);
    if (match) {
      final interceptors = <InterceptorCreator>[];
      interceptors.add(_internal.usesRequest);
      return await Interceptor.chain(
          ctx, interceptors, _internal.getJaguarInfo, routes[0]);
    }

    return null;
  }
}