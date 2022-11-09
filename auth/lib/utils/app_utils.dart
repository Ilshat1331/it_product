import 'dart:io';

import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"];
      //TODO change SECRET_KEY
      final jwtClaim = verifyJwtHS256Signature(token, key ?? "SECRET_KEY");
      return int.parse(jwtClaim["id"].toString());
    } catch (_) {
      rethrow;
    }
  }
}
