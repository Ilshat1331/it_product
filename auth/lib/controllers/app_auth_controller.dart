import 'package:auth/models/response_model.dart';
import 'package:conduit/conduit.dart';

import '../models/user.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.email == null) {
      return Response.badRequest(
        body: ResponseModel(
          message: "Password and email fields is required.",
        ),
      );
    }

    final User fetchedUser = User();

    //TODO: connect to db
    //TODO: find user
    //TODO: check password
    //TODO: fetch user

    return Response.ok(
      ResponseModel(
        data: {
          "id": fetchedUser.id,
          "accessToken": fetchedUser.accessToken,
          "refreshToken": fetchedUser.refreshToken,
        },
        message: "Succefull authorization.",
      ).toJson(),
    );
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

    final User fetchedUser = User();

    //TODO: connect to db
    //TODO: create user
    //TODO: fetch user

    return Response.ok(
      ResponseModel(
        data: {
          "id": fetchedUser.id,
          "accessToken": fetchedUser.accessToken,
          "refreshToken": fetchedUser.refreshToken,
        },
        message: "Succefull registration.",
      ).toJson(),
    );
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
}
