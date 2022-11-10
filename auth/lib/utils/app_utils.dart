import 'package:auth/utils/app_const.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final jwtClaim = verifyJwtHS256Signature(token, AppConst.secretKey);
      return int.parse(jwtClaim["id"].toString());
    } catch (_) {
      rethrow;
    }
  }
}
