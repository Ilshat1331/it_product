import 'dart:io';

import 'package:auth/controllers/app_auth_controller.dart';
import 'package:conduit/conduit.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    PersistentStore persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route("token/[:refresh]").link(
      () => AppAuthController(managedContext),
    );

  PersistentStore _initDatabase() {
    final username = Platform.environment["DB_USER"] ?? "admin";
    final password = Platform.environment["DB_PASSWORD"] ?? "root";
    final host = Platform.environment["DB_HOST"] ?? "localhost";
    final port = int.parse(Platform.environment["DB_PORT"] ?? "5432");
    final databaseName = Platform.environment["DB_USER"] ?? "postgres";
    return PostgreSQLPersistentStore(
      username,
      password,
      host,
      port,
      databaseName,
    );
  }
}
