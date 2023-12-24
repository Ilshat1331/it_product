import 'package:conduit_core/conduit_core.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';
import 'package:data/controllers/app_post_controller.dart';
import 'package:data/controllers/app_token_controller.dart';
import 'package:data/utils/app_env.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    PostgreSQLPersistentStore persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route("posts/[:id]")
        .link(() => AppTokenController())!
        .link(() => AppPostController(managedContext));

  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(
      AppEnv.dbUsername,
      AppEnv.dbPassword,
      AppEnv.dbHost,
      int.tryParse(AppEnv.dbPort),
      AppEnv.dbDatabaseName,
    );
  }
}
