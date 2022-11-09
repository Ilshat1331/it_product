import 'dart:io';

import 'package:auth/models/response_model.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../models/user.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.email == null) {
      return Response.badRequest(
          body:
              ResponseModel(message: "Password and email fields is required."));
    }

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.email).equalTo(user.email)
        ..returningProperties((table) => [
              table.id,
              table.salt,
              table.hashPassword,
            ]);

      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input("User not found.", []);
      }
      final requestHashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if (requestHashPassword == findUser.hashPassword) {
        await updateTokens(findUser.id ?? -1, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(findUser.id);
        return Response.ok(ResponseModel(
          data: user?.backing.contents,
          message: "Successful authorization.",
        ));
      } else {
        throw QueryException.input("Invalid password.", []);
      }
    } on QueryException catch (error) {
      return Response.serverError(body: ResponseModel(message: error.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.email == null || user.username == null) {
      return Response.badRequest(
        body: ResponseModel(
          message: "Password, email and username fields is required.",
        ),
      );
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
        await updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return Response.ok(
        ResponseModel(
            data: userData?.backing.contents,
            message: "Successful registration."),
      );
    } on QueryException catch (error) {
      return Response.serverError(body: ResponseModel(message: error.message));
    }
  }

  Future<void> updateTokens(int id, ManagedContext transaction) async {
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
    final User fetchedUser = User();

    //TODO: connect db
    //TODO: find user
    //TODO: check token
    //TODO: fetch user

    return Response.ok(
      ResponseModel(
        data: {
          "id": fetchedUser.id,
          "accessToken": fetchedUser.accessToken,
          "refreshToken": fetchedUser.refreshToken,
        },
        message: "Successful token refresh.",
      ).toJson(),
    );
  }

  Map<String, dynamic> _getTokens(int id) {
    //TODO remove when release
    final key = Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
    final accessClaimSet = JwtClaim(
      maxAge: Duration(minutes: 60),
      otherClaims: {"id": id},
    );
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
