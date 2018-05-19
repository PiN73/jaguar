library example.basic_auth.server;

import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar_auth/jaguar_auth.dart';

import '../../model/model.dart';
import '../../model/auth_model_manager.dart';

final Map<String, User> kUsers = {
  '0': new User(id: '0', username: 'teja', password: 'word'),
};

final WhiteListPasswordChecker kModelManager =
    new WhiteListPasswordChecker(kUsers);

final Map<String, Book> _books = {
  '0': new Book(id: '0', name: 'Book0'),
  '1': new Book(id: '1', name: 'Book1'),
};

/// This route group contains login and logout routes
@Controller()
class AuthRoutes {
  @PostJson(path: '/login')
  @Intercept(const [jsonAuth])
  User login(Context ctx) => ctx.getVariable<User>();

  @Post(path: '/logout')
  Future logout(Context ctx) async {
    // Clear session data
    (await ctx.session).clear();
  }

  /// The authenticator
  static Future jsonAuth(Context ctx) =>
      new JsonAuth(kModelManager).before(ctx);
}

/// Collection of routes students can also access
@Controller(path: '/book')
class StudentRoutes {
  @GetJson()
  Future<List<Book>> getAllBooks(Context ctx) async {
    // Authorize. Throws 401 http error, if authorization fails!
    await Authorizer.authorize(ctx, kModelManager);

    return _books.values.toList();
  }

  @GetJson(path: '/:id')
  Future<Book> getBook(Context ctx) async {
    // Authorize. Throws 401 http error, if authorization fails!
    await Authorizer.authorize(ctx, kModelManager);

    String id = ctx.pathParams.get('id');
    return _books[id];
  }
}

@Controller(path: '/api')
class LibraryApi {
  @IncludeHandler()
  final auth = new AuthRoutes();

  @IncludeHandler()
  final books = new StudentRoutes();
}

server() async {
  final server = new Jaguar(port: 10000)..add(reflect(new LibraryApi()));
  await server.serve();
}
