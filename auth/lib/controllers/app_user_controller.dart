import 'dart:io';

import 'package:auth/models/user.dart';
import 'package:auth/utils/app_const.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';

class AppUserController extends ResourceController {
  final ManagedContext managedContext;

  AppUserController(this.managedContext);

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);
      user?.removePropertiesFromBackingMap(
          [AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(
          message: "Successful get profile", body: user?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Profile getting error.");
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() User user) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final fetchedUser = await managedContext.fetchObjectWithID<User>(id);
      final qUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.username = user.username ?? fetchedUser?.username
        ..values.email = user.email ?? fetchedUser?.email;
      await qUpdateUser.updateOne();
      final updateUser = await managedContext.fetchObjectWithID<User>(id);
      updateUser?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken,
      ]);
      return AppResponse.ok(
          message: "Successful update data",
          body: updateUser?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Failed update data");
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query("oldPassword") String oldPassword,
    @Bind.query("newPassword") String newPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((table) => [table.salt, table.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      final salt = findUser?.salt ?? "";
      final oldPasswordHash = generatePasswordHash(oldPassword, salt);
      if (oldPasswordHash != findUser?.hashPassword) {
        return AppResponse.badRequest(message: "Invalid password.");
      }
      final newPasswordHash = generatePasswordHash(newPassword, salt);
      final qUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.hashPassword = newPasswordHash;
      await qUpdateUser.updateOne();
      return AppResponse.ok(message: "Successful update password.");
    } catch (error) {
      return AppResponse.serverError(error, message: "Failed update password.");
    }
  }
}
