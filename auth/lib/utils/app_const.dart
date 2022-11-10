import 'dart:io';

abstract class AppConst {
  AppConst._();
  static final String secretKey =
      Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
  static const String accessToken = "accessToken";
  static const String refreshToken = "refreshToken";
}
