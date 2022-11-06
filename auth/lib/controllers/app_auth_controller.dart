import 'package:auth/models/response_model.dart';
import 'package:conduit/conduit.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);
  @Operation.post()
  Future<Response> signIn() async {
    return Response.ok(
      ResponseModel(
        data: {
          "id": "1",
          "accessToken": "accessToken",
          "refreshToken": "refreshToken",
        },
        message: "SIGN IN OK.",
      ).toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp() async {
    return Response.ok(
      ResponseModel(
        data: {
          "id": "1",
          "accessToken": "accessToken",
          "refreshToken": "refreshToken",
        },
        message: "SIGN UP OK.",
      ).toJson(),
    );
  }

  @Operation.post("refresh")
  Future<Response> refreshToken() async {
    return Response.unauthorized(
      body: ResponseModel(error: "Token is not valid.").toJson(),
    );
  }
}
