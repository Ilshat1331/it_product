import 'package:auth/models/response.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static ResponseModel _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return ResponseModel(
        error: error.toString(),
        message: message ?? error.message,
      );
    }
    if (error is JwtException) {
      return ResponseModel(
        error: error.toString(),
        message: message ?? error.message,
      );
    }
    return ResponseModel(
      error: error.toString(),
      message: message ?? "Unknown error.",
    );
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(ResponseModel(
          data: body,
          message: message,
        ));

  AppResponse.unauthorized(dynamic error, {String? message})
      : super.unauthorized(body: _getResponseModel(error, message));

  AppResponse.badRequest({String? message})
      : super.badRequest(
            body: ResponseModel(message: message ?? "Request error."));
}
