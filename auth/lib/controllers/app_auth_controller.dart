import 'package:auth/utils/app_env.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../models/user.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.email == null) {
      return AppResponse.badRequest(
          message: "Password and email fields is required.");
    }

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.email).equalTo(user.email)
        ..returningProperties(
          (table) => [
            table.id,
            table.salt,
            table.hashPassword,
          ],
        );

      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input("User not found.", []);
      }
      final requestHashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if (requestHashPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(findUser.id);
        return AppResponse.ok(
          body: user?.backing.contents,
          message: "Successful authorization.",
        );
      } else {
        throw QueryException.input("Invalid password.", []);
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Authorisation Error.");
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.email == null || user.username == null) {
      return AppResponse.badRequest(
          message: "Password, email and username fields is required.");
    }

    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"];
        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
          body: userData?.backing.contents,
          message: "Successful registration.");
    } catch (error) {
      return AppResponse.serverError(error, message: "Registration Error.");
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];
    await qUpdateTokens.updateOne();
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken) {
        return AppResponse.unauthorized(
          "Not authorized",
          message: "Token is not valid.",
        );
      } else {
        await _updateTokens(id, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(id);
        return AppResponse.ok(
          body: user?.backing.contents,
          message: "Successful refresh of tokens.",
        );
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Refresh token Error.");
    }
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = AppEnv.secretKey;
    final accessClaimSet = JwtClaim(
      maxAge: Duration(minutes: AppEnv.time),
      otherClaims: {"id": id},
    );
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
