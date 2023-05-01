/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../protocol.dart';

class ServerApiException implements Exception {
  final ServerResponseCode? code;
  final ServerResponseType type;

  ServerApiException({this.code, required this.type});
  ServerApiException.error(this.code) : type = ServerResponseType.error;

  @override
  String toString() {
    return 'ServerApiException{code: $code, type: $type}';
  }
}

class ServerException implements Exception {
  final ServerResponseType type;
  final ServerResponseCode? code;

  ServerException({required this.type, this.code});

  @override
  String toString() {
    return "ServerException: type:$type, code:$code";
  }
}

enum ServerResponseType {
  none,
  ok,
  error,
  notAuthenticated
}

enum ServerResponseCode {
  incorrectPassword,
  securityStatusError,
  securityTimeCheckError,
  passwordMismatch,
  unknownCommand,
  notImplemented,
  dataValidationError,
  insufficientPrivilegeError,
  resetPasswordFailed,
  designatedTargetNotExist,
  illegalOperationForCurrentState,
  cannotDeleteObjectInUse,
  duplicatedEmailNotAllowed,
  internalServerError,
  mustSpecifyValidStore,
  invalidRedeemCode,
  notEnoughPoints,
}
