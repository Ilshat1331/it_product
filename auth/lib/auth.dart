import 'package:auth/controllers/app_auth_controller.dart';
import 'package:auth/controllers/app_token_controller.dart';
import 'package:auth/controllers/app_user_controller.dart';
import 'package:auth/utils/app_env.dart';
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
    )
    ..route("user")
        .link(() => AppTokenController())!
        .link(() => AppUserController(managedContext));

  PersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(
      AppEnv.dbUsername,
      AppEnv.dbPassword,
      AppEnv.dbHost,
      int.tryParse(AppEnv.port),
      AppEnv.dbDatabaseName,
    );
  }
}
