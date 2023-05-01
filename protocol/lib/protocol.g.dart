// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelContext _$ChannelContextFromJson(Map<String, dynamic> json) =>
    ChannelContext(
      json['cid'] as String,
    );

Map<String, dynamic> _$ChannelContextToJson(ChannelContext instance) =>
    <String, dynamic>{
      'cid': instance.cid,
    };

ImageSet _$ImageSetFromJson(Map<String, dynamic> json) => ImageSet(
      searchUrl: json['searchUrl'] as String,
      imageList:
          (json['imageList'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ImageSetToJson(ImageSet instance) => <String, dynamic>{
      'searchUrl': instance.searchUrl,
      'imageList': instance.imageList,
    };

ImageDefinitions _$ImageDefinitionsFromJson(Map<String, dynamic> json) =>
    ImageDefinitions(
      coffeeShop: ImageSet.fromJson(json['coffeeShop'] as Map<String, dynamic>),
      drinks: ImageSet.fromJson(json['drinks'] as Map<String, dynamic>),
      coffee: ImageSet.fromJson(json['coffee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImageDefinitionsToJson(ImageDefinitions instance) =>
    <String, dynamic>{
      'coffeeShop': instance.coffeeShop.toJson(),
      'drinks': instance.drinks.toJson(),
      'coffee': instance.coffee.toJson(),
    };

ServerCommand _$ServerCommandFromJson(Map<String, dynamic> json) =>
    ServerCommand(
      queryUserCommand: json['queryUserCommand'] == null
          ? null
          : QueryUserCommand.fromJson(
              json['queryUserCommand'] as Map<String, dynamic>),
      updateUserCommand: json['updateUserCommand'] == null
          ? null
          : UpdateUserCommand.fromJson(
              json['updateUserCommand'] as Map<String, dynamic>),
      resetPasswordCommand: json['resetPasswordCommand'] == null
          ? null
          : ResetPasswordCommand.fromJson(
              json['resetPasswordCommand'] as Map<String, dynamic>),
      queryMockMessageCommand: json['queryMockMessageCommand'] == null
          ? null
          : QueryMockMessageCommand.fromJson(
              json['queryMockMessageCommand'] as Map<String, dynamic>),
      waitForNotificationCommand: json['waitForNotificationCommand'] == null
          ? null
          : WaitForNotificationCommand.fromJson(
              json['waitForNotificationCommand'] as Map<String, dynamic>),
      updateStoreCommand: json['updateStoreCommand'] == null
          ? null
          : UpdateStoreCommand.fromJson(
              json['updateStoreCommand'] as Map<String, dynamic>),
      updateGuestCommand: json['updateGuestCommand'] == null
          ? null
          : UpdateGuestCommand.fromJson(
              json['updateGuestCommand'] as Map<String, dynamic>),
      registerAccountCommand: json['registerAccountCommand'] == null
          ? null
          : RegisterAccountCommand.fromJson(
              json['registerAccountCommand'] as Map<String, dynamic>),
      bindAccountCommand: json['bindAccountCommand'] == null
          ? null
          : BindAccountCommand.fromJson(
              json['bindAccountCommand'] as Map<String, dynamic>),
      guestLoginCommand: json['guestLoginCommand'] == null
          ? null
          : GuestLoginCommand.fromJson(
              json['guestLoginCommand'] as Map<String, dynamic>),
      updateRedeemPolicyCommand: json['updateRedeemPolicyCommand'] == null
          ? null
          : UpdateRedeemPolicyCommand.fromJson(
              json['updateRedeemPolicyCommand'] as Map<String, dynamic>),
      queryRedeemPolicyCommand: json['queryRedeemPolicyCommand'] == null
          ? null
          : QueryRedeemPolicyCommand.fromJson(
              json['queryRedeemPolicyCommand'] as Map<String, dynamic>),
      queryGuestSuppInfoCommand: json['queryGuestSuppInfoCommand'] == null
          ? null
          : QueryGuestSuppInfoCommand.fromJson(
              json['queryGuestSuppInfoCommand'] as Map<String, dynamic>),
      updateGuestSuppInfoCommand: json['updateGuestSuppInfoCommand'] == null
          ? null
          : UpdateGuestSuppInfoCommand.fromJson(
              json['updateGuestSuppInfoCommand'] as Map<String, dynamic>),
      queryStoreCommand: json['queryStoreCommand'] == null
          ? null
          : QueryStoreCommand.fromJson(
              json['queryStoreCommand'] as Map<String, dynamic>),
      queryTransactionCommand: json['queryTransactionCommand'] == null
          ? null
          : QueryTransactionCommand.fromJson(
              json['queryTransactionCommand'] as Map<String, dynamic>),
      addUserToStoreCommand: json['addUserToStoreCommand'] == null
          ? null
          : AddUserToStoreCommand.fromJson(
              json['addUserToStoreCommand'] as Map<String, dynamic>),
      updateTransactionCommand: json['updateTransactionCommand'] == null
          ? null
          : UpdateTransactionCommand.fromJson(
              json['updateTransactionCommand'] as Map<String, dynamic>),
      queryGuestCommand: json['queryGuestCommand'] == null
          ? null
          : QueryGuestCommand.fromJson(
              json['queryGuestCommand'] as Map<String, dynamic>),
      queryGuestInfoCommand: json['queryGuestInfoCommand'] == null
          ? null
          : QueryGuestInfoCommand.fromJson(
              json['queryGuestInfoCommand'] as Map<String, dynamic>),
      generateCodeCommand: json['generateCodeCommand'] == null
          ? null
          : GenerateCodeCommand.fromJson(
              json['generateCodeCommand'] as Map<String, dynamic>),
      redeemForCodeCommand: json['redeemForCodeCommand'] == null
          ? null
          : RedeemForCodeCommand.fromJson(
              json['redeemForCodeCommand'] as Map<String, dynamic>),
      updateMockMessageCommand: json['updateMockMessageCommand'] == null
          ? null
          : UpdateMockMessageCommand.fromJson(
              json['updateMockMessageCommand'] as Map<String, dynamic>),
    )
      ..channel = json['channel'] == null
          ? null
          : ChannelContext.fromJson(json['channel'] as Map<String, dynamic>)
      ..adminCommand = json['adminCommand'] == null
          ? null
          : AdminCommand.fromJson(json['adminCommand'] as Map<String, dynamic>)
      ..getPropCommand = json['getPropCommand'] == null
          ? null
          : GetPropCommand.fromJson(
              json['getPropCommand'] as Map<String, dynamic>)
      ..updatePropCommand = json['updatePropCommand'] == null
          ? null
          : UpdatePropCommand.fromJson(
              json['updatePropCommand'] as Map<String, dynamic>)
      ..loginCommand = json['loginCommand'] == null
          ? null
          : LoginCommand.fromJson(json['loginCommand'] as Map<String, dynamic>)
      ..changePasswordCommand = json['changePasswordCommand'] == null
          ? null
          : ChangePasswordCommand.fromJson(
              json['changePasswordCommand'] as Map<String, dynamic>);

Map<String, dynamic> _$ServerCommandToJson(ServerCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('channel', instance.channel?.toJson());
  writeNotNull('adminCommand', instance.adminCommand?.toJson());
  writeNotNull('getPropCommand', instance.getPropCommand?.toJson());
  writeNotNull('updatePropCommand', instance.updatePropCommand?.toJson());
  writeNotNull('loginCommand', instance.loginCommand?.toJson());
  writeNotNull(
      'changePasswordCommand', instance.changePasswordCommand?.toJson());
  writeNotNull('updateStoreCommand', instance.updateStoreCommand?.toJson());
  writeNotNull('queryStoreCommand', instance.queryStoreCommand?.toJson());
  writeNotNull('updateUserCommand', instance.updateUserCommand?.toJson());
  writeNotNull('queryUserCommand', instance.queryUserCommand?.toJson());
  writeNotNull('updateGuestCommand', instance.updateGuestCommand?.toJson());
  writeNotNull('queryGuestCommand', instance.queryGuestCommand?.toJson());
  writeNotNull(
      'updateTransactionCommand', instance.updateTransactionCommand?.toJson());
  writeNotNull(
      'queryTransactionCommand', instance.queryTransactionCommand?.toJson());
  writeNotNull('resetPasswordCommand', instance.resetPasswordCommand?.toJson());
  writeNotNull(
      'queryMockMessageCommand', instance.queryMockMessageCommand?.toJson());
  writeNotNull('waitForNotificationCommand',
      instance.waitForNotificationCommand?.toJson());
  writeNotNull(
      'registerAccountCommand', instance.registerAccountCommand?.toJson());
  writeNotNull('bindAccountCommand', instance.bindAccountCommand?.toJson());
  writeNotNull('guestLoginCommand', instance.guestLoginCommand?.toJson());
  writeNotNull('updateRedeemPolicyCommand',
      instance.updateRedeemPolicyCommand?.toJson());
  writeNotNull(
      'queryRedeemPolicyCommand', instance.queryRedeemPolicyCommand?.toJson());
  writeNotNull('queryGuestSuppInfoCommand',
      instance.queryGuestSuppInfoCommand?.toJson());
  writeNotNull('updateGuestSuppInfoCommand',
      instance.updateGuestSuppInfoCommand?.toJson());
  writeNotNull(
      'addUserToStoreCommand', instance.addUserToStoreCommand?.toJson());
  writeNotNull(
      'queryGuestInfoCommand', instance.queryGuestInfoCommand?.toJson());
  writeNotNull('generateCodeCommand', instance.generateCodeCommand?.toJson());
  writeNotNull('redeemForCodeCommand', instance.redeemForCodeCommand?.toJson());
  writeNotNull(
      'updateMockMessageCommand', instance.updateMockMessageCommand?.toJson());
  return val;
}

ServerResponse _$ServerResponseFromJson(Map<String, dynamic> json) =>
    ServerResponse(
      type: $enumDecode(_$ServerResponseTypeEnumMap, json['type']),
      code: $enumDecodeNullable(_$ServerResponseCodeEnumMap, json['code']),
    )
      ..getPropResult = json['getPropResult'] == null
          ? null
          : GetPropResult.fromJson(
              json['getPropResult'] as Map<String, dynamic>)
      ..loginResponse = json['loginResponse'] == null
          ? null
          : LoginResponse.fromJson(
              json['loginResponse'] as Map<String, dynamic>)
      ..updateRecordResponse = json['updateRecordResponse'] == null
          ? null
          : UpdateRecordResponse.fromJson(
              json['updateRecordResponse'] as Map<String, dynamic>)
      ..queryStoreResponse = json['queryStoreResponse'] == null
          ? null
          : QueryStoreResponse.fromJson(
              json['queryStoreResponse'] as Map<String, dynamic>)
      ..queryUserResponse = json['queryUserResponse'] == null
          ? null
          : QueryUserResponse.fromJson(
              json['queryUserResponse'] as Map<String, dynamic>)
      ..queryGuestResponse = json['queryGuestResponse'] == null
          ? null
          : QueryGuestResponse.fromJson(
              json['queryGuestResponse'] as Map<String, dynamic>)
      ..queryTransactionResponse = json['queryTransactionResponse'] == null
          ? null
          : QueryTransactionResponse.fromJson(
              json['queryTransactionResponse'] as Map<String, dynamic>)
      ..queryMockMessageResponse = json['queryMockMessageResponse'] == null
          ? null
          : QueryMockMessageResponse.fromJson(
              json['queryMockMessageResponse'] as Map<String, dynamic>)
      ..resetPasswordResponse = json['resetPasswordResponse'] == null
          ? null
          : ResetPasswordResponse.fromJson(
              json['resetPasswordResponse'] as Map<String, dynamic>)
      ..waitForNotificationResponse =
          json['waitForNotificationResponse'] == null
              ? null
              : WaitForNotificationResponse.fromJson(
                  json['waitForNotificationResponse'] as Map<String, dynamic>)
      ..bindAccountResponse = json['bindAccountResponse'] == null
          ? null
          : BindAccountResponse.fromJson(
              json['bindAccountResponse'] as Map<String, dynamic>)
      ..guestLoginResponse = json['guestLoginResponse'] == null
          ? null
          : GuestLoginResponse.fromJson(
              json['guestLoginResponse'] as Map<String, dynamic>)
      ..queryRedeemPolicyResponse = json['queryRedeemPolicyResponse'] == null
          ? null
          : QueryRedeemPolicyResponse.fromJson(
              json['queryRedeemPolicyResponse'] as Map<String, dynamic>)
      ..queryGuestSuppInfoResponse = json['queryGuestSuppInfoResponse'] == null
          ? null
          : QueryGuestSuppInfoResponse.fromJson(
              json['queryGuestSuppInfoResponse'] as Map<String, dynamic>)
      ..queryGuestInfoResponse = json['queryGuestInfoResponse'] == null
          ? null
          : QueryGuestInfoResponse.fromJson(
              json['queryGuestInfoResponse'] as Map<String, dynamic>)
      ..generateCodeResponse = json['generateCodeResponse'] == null
          ? null
          : GenerateCodeResponse.fromJson(
              json['generateCodeResponse'] as Map<String, dynamic>);

Map<String, dynamic> _$ServerResponseToJson(ServerResponse instance) {
  final val = <String, dynamic>{
    'type': _$ServerResponseTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('code', _$ServerResponseCodeEnumMap[instance.code]);
  writeNotNull('getPropResult', instance.getPropResult?.toJson());
  writeNotNull('loginResponse', instance.loginResponse?.toJson());
  writeNotNull('updateRecordResponse', instance.updateRecordResponse?.toJson());
  writeNotNull('queryStoreResponse', instance.queryStoreResponse?.toJson());
  writeNotNull('queryUserResponse', instance.queryUserResponse?.toJson());
  writeNotNull('queryGuestResponse', instance.queryGuestResponse?.toJson());
  writeNotNull(
      'queryTransactionResponse', instance.queryTransactionResponse?.toJson());
  writeNotNull(
      'queryMockMessageResponse', instance.queryMockMessageResponse?.toJson());
  writeNotNull(
      'resetPasswordResponse', instance.resetPasswordResponse?.toJson());
  writeNotNull('waitForNotificationResponse',
      instance.waitForNotificationResponse?.toJson());
  writeNotNull('bindAccountResponse', instance.bindAccountResponse?.toJson());
  writeNotNull('guestLoginResponse', instance.guestLoginResponse?.toJson());
  writeNotNull('queryRedeemPolicyResponse',
      instance.queryRedeemPolicyResponse?.toJson());
  writeNotNull('queryGuestSuppInfoResponse',
      instance.queryGuestSuppInfoResponse?.toJson());
  writeNotNull(
      'queryGuestInfoResponse', instance.queryGuestInfoResponse?.toJson());
  writeNotNull('generateCodeResponse', instance.generateCodeResponse?.toJson());
  return val;
}

const _$ServerResponseTypeEnumMap = {
  ServerResponseType.none: 'none',
  ServerResponseType.ok: 'ok',
  ServerResponseType.error: 'error',
  ServerResponseType.notAuthenticated: 'notAuthenticated',
};

const _$ServerResponseCodeEnumMap = {
  ServerResponseCode.incorrectPassword: 'incorrectPassword',
  ServerResponseCode.securityStatusError: 'securityStatusError',
  ServerResponseCode.securityTimeCheckError: 'securityTimeCheckError',
  ServerResponseCode.passwordMismatch: 'passwordMismatch',
  ServerResponseCode.unknownCommand: 'unknownCommand',
  ServerResponseCode.notImplemented: 'notImplemented',
  ServerResponseCode.dataValidationError: 'dataValidationError',
  ServerResponseCode.insufficientPrivilegeError: 'insufficientPrivilegeError',
  ServerResponseCode.resetPasswordFailed: 'resetPasswordFailed',
  ServerResponseCode.designatedTargetNotExist: 'designatedTargetNotExist',
  ServerResponseCode.illegalOperationForCurrentState:
      'illegalOperationForCurrentState',
  ServerResponseCode.cannotDeleteObjectInUse: 'cannotDeleteObjectInUse',
  ServerResponseCode.duplicatedEmailNotAllowed: 'duplicatedEmailNotAllowed',
  ServerResponseCode.internalServerError: 'internalServerError',
  ServerResponseCode.mustSpecifyValidStore: 'mustSpecifyValidStore',
  ServerResponseCode.invalidRedeemCode: 'invalidRedeemCode',
  ServerResponseCode.notEnoughPoints: 'notEnoughPoints',
};

CheckDatabase _$CheckDatabaseFromJson(Map<String, dynamic> json) =>
    CheckDatabase();

Map<String, dynamic> _$CheckDatabaseToJson(CheckDatabase instance) =>
    <String, dynamic>{};

AdminCommand _$AdminCommandFromJson(Map<String, dynamic> json) => AdminCommand()
  ..checkDatabase = json['checkDatabase'] == null
      ? null
      : CheckDatabase.fromJson(json['checkDatabase'] as Map<String, dynamic>);

Map<String, dynamic> _$AdminCommandToJson(AdminCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('checkDatabase', instance.checkDatabase?.toJson());
  return val;
}

DbPropValue _$DbPropValueFromJson(Map<String, dynamic> json) => DbPropValue(
      name: json['name'] as String,
      setup: json['setup'] == null
          ? null
          : DbPropOfSetup.fromJson(json['setup'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DbPropValueToJson(DbPropValue instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('setup', instance.setup?.toJson());
  return val;
}

DbPropOfSetup _$DbPropOfSetupFromJson(Map<String, dynamic> json) =>
    DbPropOfSetup(
      rootUser: json['rootUser'] as String?,
    );

Map<String, dynamic> _$DbPropOfSetupToJson(DbPropOfSetup instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('rootUser', instance.rootUser);
  return val;
}

UpdatePropCommand _$UpdatePropCommandFromJson(Map<String, dynamic> json) =>
    UpdatePropCommand(
      DbPropValue.fromJson(json['prop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdatePropCommandToJson(UpdatePropCommand instance) =>
    <String, dynamic>{
      'prop': instance.prop.toJson(),
    };

GetPropCommand _$GetPropCommandFromJson(Map<String, dynamic> json) =>
    GetPropCommand(
      json['name'] as String,
    );

Map<String, dynamic> _$GetPropCommandToJson(GetPropCommand instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

GetPropResult _$GetPropResultFromJson(Map<String, dynamic> json) =>
    GetPropResult(
      json['prop'] == null
          ? null
          : DbPropValue.fromJson(json['prop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetPropResultToJson(GetPropResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prop', instance.prop?.toJson());
  return val;
}

UpdateRecordResponse _$UpdateRecordResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateRecordResponse(
      newId: json['newId'] as int?,
    );

Map<String, dynamic> _$UpdateRecordResponseToJson(
    UpdateRecordResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('newId', instance.newId);
  return val;
}

QueryStoreCommand _$QueryStoreCommandFromJson(Map<String, dynamic> json) =>
    QueryStoreCommand(
      storeQueryCriteria: json['storeQueryCriteria'] == null
          ? null
          : GenStore.fromJson(
              json['storeQueryCriteria'] as Map<String, dynamic>),
      storeId: json['storeId'] as int?,
      queryUserInfo: json['queryUserInfo'] as bool?,
    );

Map<String, dynamic> _$QueryStoreCommandToJson(QueryStoreCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('storeId', instance.storeId);
  writeNotNull('storeQueryCriteria', instance.storeQueryCriteria?.toJson());
  writeNotNull('queryUserInfo', instance.queryUserInfo);
  return val;
}

QueryStoreResponse _$QueryStoreResponseFromJson(Map<String, dynamic> json) =>
    QueryStoreResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => GenStore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      linkedUsers: (json['linkedUsers'] as List<dynamic>?)
              ?.map((e) => GenUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QueryStoreResponseToJson(QueryStoreResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
      'linkedUsers': instance.linkedUsers.map((e) => e.toJson()).toList(),
    };

UpdateStoreCommand _$UpdateStoreCommandFromJson(Map<String, dynamic> json) =>
    UpdateStoreCommand(
      storeIdToDelete: json['storeIdToDelete'] as int?,
      store: json['store'] == null
          ? null
          : GenStore.fromJson(json['store'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateStoreCommandToJson(UpdateStoreCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('storeIdToDelete', instance.storeIdToDelete);
  writeNotNull('store', instance.store?.toJson());
  return val;
}

AddUserToStoreCommand _$AddUserToStoreCommandFromJson(
        Map<String, dynamic> json) =>
    AddUserToStoreCommand(
      email: json['email'] as String,
      storeId: json['storeId'] as int,
      role: $enumDecode(_$UserRoleAtStoreEnumMap, json['role']),
    );

Map<String, dynamic> _$AddUserToStoreCommandToJson(
        AddUserToStoreCommand instance) =>
    <String, dynamic>{
      'email': instance.email,
      'storeId': instance.storeId,
      'role': _$UserRoleAtStoreEnumMap[instance.role]!,
    };

const _$UserRoleAtStoreEnumMap = {
  UserRoleAtStore.manager: 'manager',
  UserRoleAtStore.staff: 'staff',
};

StoreUser _$StoreUserFromJson(Map<String, dynamic> json) => StoreUser(
      storeId: json['storeId'] as int?,
      uid: json['uid'] as int,
      role: $enumDecode(_$UserRoleAtStoreEnumMap, json['role']),
    );

Map<String, dynamic> _$StoreUserToJson(StoreUser instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('storeId', instance.storeId);
  val['uid'] = instance.uid;
  val['role'] = _$UserRoleAtStoreEnumMap[instance.role]!;
  return val;
}

GenStore _$GenStoreFromJson(Map<String, dynamic> json) => GenStore(
      storeId: json['storeId'] as int?,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      status: $enumDecodeNullable(_$StoreStatusEnumMap, json['status']) ??
          StoreStatus.normal,
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => StoreUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usersChanged: json['usersChanged'] as bool?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$GenStoreToJson(GenStore instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('storeId', instance.storeId);
  val['name'] = instance.name;
  val['address'] = instance.address;
  val['phone'] = instance.phone;
  val['status'] = _$StoreStatusEnumMap[instance.status]!;
  val['users'] = instance.users.map((e) => e.toJson()).toList();
  writeNotNull('usersChanged', instance.usersChanged);
  writeNotNull('imageUrl', instance.imageUrl);
  return val;
}

const _$StoreStatusEnumMap = {
  StoreStatus.normal: 'normal',
  StoreStatus.suspended: 'suspended',
};

LoginCommand _$LoginCommandFromJson(Map<String, dynamic> json) => LoginCommand(
      email: json['email'] as String,
      actuatedHashedPassword: json['actuatedHashedPassword'] as String,
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$LoginCommandToJson(LoginCommand instance) =>
    <String, dynamic>{
      'email': instance.email,
      'actuatedHashedPassword': instance.actuatedHashedPassword,
      'time': instance.time.toIso8601String(),
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      json['uid'] as int,
      ChannelContext.fromJson(json['channel'] as Map<String, dynamic>),
    )..loggedInUser = json['loggedInUser'] == null
        ? null
        : GenUser.fromJson(json['loggedInUser'] as Map<String, dynamic>);

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) {
  final val = <String, dynamic>{
    'uid': instance.uid,
    'channel': instance.channel.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('loggedInUser', instance.loggedInUser?.toJson());
  return val;
}

QueryUserCommand _$QueryUserCommandFromJson(Map<String, dynamic> json) =>
    QueryUserCommand(
      userQueryCriteria: json['userQueryCriteria'] == null
          ? null
          : GenUser.fromJson(json['userQueryCriteria'] as Map<String, dynamic>),
      uid: json['uid'] as int?,
      managingStoreId: json['managingStoreId'] as int?,
      queryStoreInfo: json['queryStoreInfo'] as bool?,
    );

Map<String, dynamic> _$QueryUserCommandToJson(QueryUserCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('uid', instance.uid);
  writeNotNull('userQueryCriteria', instance.userQueryCriteria?.toJson());
  writeNotNull('managingStoreId', instance.managingStoreId);
  writeNotNull('queryStoreInfo', instance.queryStoreInfo);
  return val;
}

QueryUserResponse _$QueryUserResponseFromJson(Map<String, dynamic> json) =>
    QueryUserResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => GenUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      stores: (json['stores'] as List<dynamic>?)
              ?.map((e) => GenStore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QueryUserResponseToJson(QueryUserResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
      'stores': instance.stores.map((e) => e.toJson()).toList(),
    };

UpdateUserCommand _$UpdateUserCommandFromJson(Map<String, dynamic> json) =>
    UpdateUserCommand(
      userIdToDelete: json['userIdToDelete'] as int?,
      user: json['user'] == null
          ? null
          : GenUser.fromJson(json['user'] as Map<String, dynamic>),
      assignPassword: json['assignPassword'] as bool?,
      managingStoreId: json['managingStoreId'] as int?,
    );

Map<String, dynamic> _$UpdateUserCommandToJson(UpdateUserCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userIdToDelete', instance.userIdToDelete);
  writeNotNull('user', instance.user?.toJson());
  writeNotNull('assignPassword', instance.assignPassword);
  writeNotNull('managingStoreId', instance.managingStoreId);
  return val;
}

ChangePasswordCommand _$ChangePasswordCommandFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordCommand(
      json['oldPasswordHash'] as String,
      json['newPasswordHash'] as String,
    );

Map<String, dynamic> _$ChangePasswordCommandToJson(
        ChangePasswordCommand instance) =>
    <String, dynamic>{
      'oldPasswordHash': instance.oldPasswordHash,
      'newPasswordHash': instance.newPasswordHash,
    };

GenUser _$GenUserFromJson(Map<String, dynamic> json) => GenUser(
      uid: json['uid'] as int?,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      fAdmin: json['fAdmin'] as bool? ?? false,
      lastLoggedIn: json['lastLoggedIn'] == null
          ? null
          : DateTime.parse(json['lastLoggedIn'] as String),
      hashedPassword: json['hashedPassword'] as String?,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.normal,
      plainPassword: json['plainPassword'] as String?,
    )..stores = (json['stores'] as List<dynamic>)
        .map((e) => StoreUser.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$GenUserToJson(GenUser instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('uid', instance.uid);
  val['email'] = instance.email;
  val['fullName'] = instance.fullName;
  writeNotNull('hashedPassword', instance.hashedPassword);
  writeNotNull('created', instance.created?.toIso8601String());
  writeNotNull('lastUpdated', instance.lastUpdated?.toIso8601String());
  writeNotNull('lastLoggedIn', instance.lastLoggedIn?.toIso8601String());
  val['fAdmin'] = instance.fAdmin;
  val['phone'] = instance.phone;
  val['stores'] = instance.stores.map((e) => e.toJson()).toList();
  val['status'] = _$UserStatusEnumMap[instance.status]!;
  writeNotNull('plainPassword', instance.plainPassword);
  return val;
}

const _$UserStatusEnumMap = {
  UserStatus.normal: 'normal',
  UserStatus.suspended: 'suspended',
};

GuestLoginCommand _$GuestLoginCommandFromJson(Map<String, dynamic> json) =>
    GuestLoginCommand(
      phone: json['phone'] as String,
      actuatedHashedPassword: json['actuatedHashedPassword'] as String,
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$GuestLoginCommandToJson(GuestLoginCommand instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'actuatedHashedPassword': instance.actuatedHashedPassword,
      'time': instance.time.toIso8601String(),
    };

GuestLoginResponse _$GuestLoginResponseFromJson(Map<String, dynamic> json) =>
    GuestLoginResponse(
      guestId: json['guestId'] as int,
      channel: ChannelContext.fromJson(json['channel'] as Map<String, dynamic>),
      loggedInGuest:
          GenGuest.fromJson(json['loggedInGuest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GuestLoginResponseToJson(GuestLoginResponse instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'channel': instance.channel.toJson(),
      'loggedInGuest': instance.loggedInGuest.toJson(),
    };

QueryGuestCommand _$QueryGuestCommandFromJson(Map<String, dynamic> json) =>
    QueryGuestCommand(
      guestQueryCriteria: json['guestQueryCriteria'] == null
          ? null
          : GenGuest.fromJson(
              json['guestQueryCriteria'] as Map<String, dynamic>),
      guestId: json['guestId'] as int?,
      managingStoreId: json['managingStoreId'] as int?,
    );

Map<String, dynamic> _$QueryGuestCommandToJson(QueryGuestCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guestId', instance.guestId);
  writeNotNull('guestQueryCriteria', instance.guestQueryCriteria?.toJson());
  writeNotNull('managingStoreId', instance.managingStoreId);
  return val;
}

QueryGuestResponse _$QueryGuestResponseFromJson(Map<String, dynamic> json) =>
    QueryGuestResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => GenGuest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QueryGuestResponseToJson(QueryGuestResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
    };

UpdateGuestCommand _$UpdateGuestCommandFromJson(Map<String, dynamic> json) =>
    UpdateGuestCommand(
      guestIdToDelete: json['guestIdToDelete'] as int?,
      guest: json['guest'] == null
          ? null
          : GenGuest.fromJson(json['guest'] as Map<String, dynamic>),
      assignPassword: json['assignPassword'] as bool?,
    );

Map<String, dynamic> _$UpdateGuestCommandToJson(UpdateGuestCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guestIdToDelete', instance.guestIdToDelete);
  writeNotNull('guest', instance.guest?.toJson());
  writeNotNull('assignPassword', instance.assignPassword);
  return val;
}

QueryGuestSuppInfoCommand _$QueryGuestSuppInfoCommandFromJson(
        Map<String, dynamic> json) =>
    QueryGuestSuppInfoCommand();

Map<String, dynamic> _$QueryGuestSuppInfoCommandToJson(
        QueryGuestSuppInfoCommand instance) =>
    <String, dynamic>{};

QueryGuestSuppInfoResponse _$QueryGuestSuppInfoResponseFromJson(
        Map<String, dynamic> json) =>
    QueryGuestSuppInfoResponse(
      guestSuppInfo: json['guestSuppInfo'] == null
          ? null
          : GuestSuppInfo.fromJson(
              json['guestSuppInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryGuestSuppInfoResponseToJson(
    QueryGuestSuppInfoResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guestSuppInfo', instance.guestSuppInfo?.toJson());
  return val;
}

UpdateGuestSuppInfoCommand _$UpdateGuestSuppInfoCommandFromJson(
        Map<String, dynamic> json) =>
    UpdateGuestSuppInfoCommand(
      guestSuppInfo:
          GuestSuppInfo.fromJson(json['guestSuppInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateGuestSuppInfoCommandToJson(
        UpdateGuestSuppInfoCommand instance) =>
    <String, dynamic>{
      'guestSuppInfo': instance.guestSuppInfo.toJson(),
    };

QueryGuestInfoCommand _$QueryGuestInfoCommandFromJson(
        Map<String, dynamic> json) =>
    QueryGuestInfoCommand();

Map<String, dynamic> _$QueryGuestInfoCommandToJson(
        QueryGuestInfoCommand instance) =>
    <String, dynamic>{};

QueryGuestInfoResponse _$QueryGuestInfoResponseFromJson(
        Map<String, dynamic> json) =>
    QueryGuestInfoResponse(
      guest: json['guest'] == null
          ? null
          : GenGuest.fromJson(json['guest'] as Map<String, dynamic>),
      pointsRemaining: json['pointsRemaining'] as int?,
    );

Map<String, dynamic> _$QueryGuestInfoResponseToJson(
    QueryGuestInfoResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guest', instance.guest?.toJson());
  writeNotNull('pointsRemaining', instance.pointsRemaining);
  return val;
}

GuestSuppInfo _$GuestSuppInfoFromJson(Map<String, dynamic> json) =>
    GuestSuppInfo(
      guestId: json['guestId'] as int,
      favoritePolicyIds: (json['favoritePolicyIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GuestSuppInfoToJson(GuestSuppInfo instance) =>
    <String, dynamic>{
      'guestId': instance.guestId,
      'favoritePolicyIds': instance.favoritePolicyIds,
    };

GenGuest _$GenGuestFromJson(Map<String, dynamic> json) => GenGuest(
      guestId: json['guestId'] as int?,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      email: json['email'] as String?,
      status: $enumDecodeNullable(_$GuestStatusEnumMap, json['status']) ??
          GuestStatus.normal,
      hashedPassword: json['hashedPassword'] as String?,
      plainPassword: json['plainPassword'] as String?,
    )
      ..created = json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String)
      ..lastUpdated = json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String)
      ..lastLoggedIn = json['lastLoggedIn'] == null
          ? null
          : DateTime.parse(json['lastLoggedIn'] as String);

Map<String, dynamic> _$GenGuestToJson(GenGuest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guestId', instance.guestId);
  val['fullName'] = instance.fullName;
  val['phone'] = instance.phone;
  val['gender'] = _$GenderEnumMap[instance.gender]!;
  writeNotNull('birthday', instance.birthday?.toIso8601String());
  writeNotNull('email', instance.email);
  val['status'] = _$GuestStatusEnumMap[instance.status]!;
  writeNotNull('created', instance.created?.toIso8601String());
  writeNotNull('lastUpdated', instance.lastUpdated?.toIso8601String());
  writeNotNull('lastLoggedIn', instance.lastLoggedIn?.toIso8601String());
  writeNotNull('hashedPassword', instance.hashedPassword);
  writeNotNull('plainPassword', instance.plainPassword);
  return val;
}

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unspecified: 'unspecified',
};

const _$GuestStatusEnumMap = {
  GuestStatus.normal: 'normal',
  GuestStatus.suspended: 'suspended',
};

PasswordReassignmentRec _$PasswordReassignmentRecFromJson(
        Map<String, dynamic> json) =>
    PasswordReassignmentRec(
      identityType: $enumDecode(_$IdentityTypeEnumMap, json['identityType']),
      resetPasswordType:
          $enumDecode(_$ResetPasswordTypeEnumMap, json['resetPasswordType']),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    )
      ..authKey = json['authKey'] as String?
      ..otpCode = json['otpCode'] as String?
      ..time =
          json['time'] == null ? null : DateTime.parse(json['time'] as String);

Map<String, dynamic> _$PasswordReassignmentRecToJson(
    PasswordReassignmentRec instance) {
  final val = <String, dynamic>{
    'identityType': _$IdentityTypeEnumMap[instance.identityType]!,
    'resetPasswordType':
        _$ResetPasswordTypeEnumMap[instance.resetPasswordType]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('phone', instance.phone);
  writeNotNull('authKey', instance.authKey);
  writeNotNull('otpCode', instance.otpCode);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}

const _$IdentityTypeEnumMap = {
  IdentityType.user: 'user',
  IdentityType.guest: 'guest',
};

const _$ResetPasswordTypeEnumMap = {
  ResetPasswordType.email: 'email',
  ResetPasswordType.phone: 'phone',
};

ResetPasswordResponse _$ResetPasswordResponseFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordResponse(
      generatedPassword: json['generatedPassword'] as String?,
    );

Map<String, dynamic> _$ResetPasswordResponseToJson(
    ResetPasswordResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('generatedPassword', instance.generatedPassword);
  return val;
}

AssignPasswordByAdmin _$AssignPasswordByAdminFromJson(
        Map<String, dynamic> json) =>
    AssignPasswordByAdmin(
      userEmail: json['userEmail'] as String?,
      passwordPlain: json['passwordPlain'] as String,
    );

Map<String, dynamic> _$AssignPasswordByAdminToJson(
    AssignPasswordByAdmin instance) {
  final val = <String, dynamic>{
    'passwordPlain': instance.passwordPlain,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userEmail', instance.userEmail);
  return val;
}

ResetPasswordCommand _$ResetPasswordCommandFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordCommand(
      passwordReassignment: json['passwordReassignment'] == null
          ? null
          : PasswordReassignmentRec.fromJson(
              json['passwordReassignment'] as Map<String, dynamic>),
      enteredAuthKey: json['enteredAuthKey'] as String?,
      enteredOtpCode: json['enteredOtpCode'] as String?,
      assignPasswordByAdmin: json['assignPasswordByAdmin'] == null
          ? null
          : AssignPasswordByAdmin.fromJson(
              json['assignPasswordByAdmin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResetPasswordCommandToJson(
    ResetPasswordCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('passwordReassignment', instance.passwordReassignment?.toJson());
  writeNotNull('enteredOtpCode', instance.enteredOtpCode);
  writeNotNull('enteredAuthKey', instance.enteredAuthKey);
  writeNotNull(
      'assignPasswordByAdmin', instance.assignPasswordByAdmin?.toJson());
  return val;
}

RegisterAccountCommand _$RegisterAccountCommandFromJson(
        Map<String, dynamic> json) =>
    RegisterAccountCommand(
      type: $enumDecode(_$IdentityTypeEnumMap, json['type']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$RegisterAccountCommandToJson(
    RegisterAccountCommand instance) {
  final val = <String, dynamic>{
    'type': _$IdentityTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('phone', instance.phone);
  writeNotNull('email', instance.email);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}

BindAccountCommand _$BindAccountCommandFromJson(Map<String, dynamic> json) =>
    BindAccountCommand(
      action: $enumDecode(_$BindAccountCommandActionEnumMap, json['action']),
      enteredOtpCode: json['enteredOtpCode'] as String?,
      guest: json['guest'] == null
          ? null
          : GenGuest.fromJson(json['guest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BindAccountCommandToJson(BindAccountCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('enteredOtpCode', instance.enteredOtpCode);
  val['action'] = _$BindAccountCommandActionEnumMap[instance.action]!;
  writeNotNull('guest', instance.guest?.toJson());
  return val;
}

const _$BindAccountCommandActionEnumMap = {
  BindAccountCommandAction.query: 'query',
  BindAccountCommandAction.update: 'update',
};

BindAccountResponse _$BindAccountResponseFromJson(Map<String, dynamic> json) =>
    BindAccountResponse(
      guest: json['guest'] == null
          ? null
          : GenGuest.fromJson(json['guest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BindAccountResponseToJson(BindAccountResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guest', instance.guest?.toJson());
  return val;
}

MockMessageQuery _$MockMessageQueryFromJson(Map<String, dynamic> json) =>
    MockMessageQuery(
      queryType: $enumDecode(_$MockMessageQueryTypeEnumMap, json['queryType']),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$MockMessageQueryToJson(MockMessageQuery instance) {
  final val = <String, dynamic>{
    'queryType': _$MockMessageQueryTypeEnumMap[instance.queryType]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('phone', instance.phone);
  return val;
}

const _$MockMessageQueryTypeEnumMap = {
  MockMessageQueryType.server: 'server',
  MockMessageQueryType.phone: 'phone',
  MockMessageQueryType.email: 'email',
};

QueryMockMessageCommand _$QueryMockMessageCommandFromJson(
        Map<String, dynamic> json) =>
    QueryMockMessageCommand(
      queryList: (json['queryList'] as List<dynamic>)
          .map((e) => MockMessageQuery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QueryMockMessageCommandToJson(
        QueryMockMessageCommand instance) =>
    <String, dynamic>{
      'queryList': instance.queryList.map((e) => e.toJson()).toList(),
    };

NotificationSpec _$NotificationSpecFromJson(Map<String, dynamic> json) =>
    NotificationSpec(
      id: json['id'] as int,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$NotificationSpecToJson(NotificationSpec instance) {
  final val = <String, dynamic>{
    'type': _$NotificationTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('phone', instance.phone);
  val['id'] = instance.id;
  return val;
}

const _$NotificationTypeEnumMap = {
  NotificationType.mockMessageForEmail: 'mockMessageForEmail',
  NotificationType.mockMessageForPhone: 'mockMessageForPhone',
};

WaitForNotificationCommand _$WaitForNotificationCommandFromJson(
        Map<String, dynamic> json) =>
    WaitForNotificationCommand(
      waitList: (json['waitList'] as List<dynamic>)
          .map((e) => NotificationSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
      waitSeconds: json['waitSeconds'] as int,
    );

Map<String, dynamic> _$WaitForNotificationCommandToJson(
        WaitForNotificationCommand instance) =>
    <String, dynamic>{
      'waitList': instance.waitList.map((e) => e.toJson()).toList(),
      'waitSeconds': instance.waitSeconds,
    };

WaitForNotificationResponse _$WaitForNotificationResponseFromJson(
        Map<String, dynamic> json) =>
    WaitForNotificationResponse(
      eventfulIds:
          (json['eventfulIds'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$WaitForNotificationResponseToJson(
        WaitForNotificationResponse instance) =>
    <String, dynamic>{
      'eventfulIds': instance.eventfulIds,
    };

QueryMockMessageResponse _$QueryMockMessageResponseFromJson(
        Map<String, dynamic> json) =>
    QueryMockMessageResponse(
      result: (json['result'] as List<dynamic>)
          .map((e) => MockMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QueryMockMessageResponseToJson(
        QueryMockMessageResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
    };

UpdateMockMessageCommand _$UpdateMockMessageCommandFromJson(
        Map<String, dynamic> json) =>
    UpdateMockMessageCommand(
      idToDelete: json['idToDelete'] as int?,
    );

Map<String, dynamic> _$UpdateMockMessageCommandToJson(
    UpdateMockMessageCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('idToDelete', instance.idToDelete);
  return val;
}

MockMessage _$MockMessageFromJson(Map<String, dynamic> json) => MockMessage(
      type: $enumDecode(_$MockMessageTypeEnumMap, json['type']),
      email: json['email'] as String?,
      subject: json['subject'] as String?,
      phone: json['phone'] as String?,
      content: json['content'] as String?,
      authKey: json['authKey'] as String?,
      otpCode: json['otpCode'] as String?,
      time: DateTime.parse(json['time'] as String),
    )
      ..id = json['id'] as int?
      ..read = json['read'] as bool?;

Map<String, dynamic> _$MockMessageToJson(MockMessage instance) {
  final val = <String, dynamic>{
    'type': _$MockMessageTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('email', instance.email);
  writeNotNull('subject', instance.subject);
  writeNotNull('phone', instance.phone);
  val['time'] = instance.time.toIso8601String();
  writeNotNull('content', instance.content);
  writeNotNull('authKey', instance.authKey);
  writeNotNull('otpCode', instance.otpCode);
  writeNotNull('read', instance.read);
  return val;
}

const _$MockMessageTypeEnumMap = {
  MockMessageType.email: 'email',
  MockMessageType.sms: 'sms',
};

QueryTransactionCommand _$QueryTransactionCommandFromJson(
        Map<String, dynamic> json) =>
    QueryTransactionCommand(
      xid: json['xid'] as int?,
      guestId: json['guestId'] as int?,
      xtranQueryCriteria: json['xtranQueryCriteria'] == null
          ? null
          : GenTransaction.fromJson(
              json['xtranQueryCriteria'] as Map<String, dynamic>),
      managingStoreId: json['managingStoreId'] as int?,
      queryLinkedInfo: json['queryLinkedInfo'] as bool?,
    );

Map<String, dynamic> _$QueryTransactionCommandToJson(
    QueryTransactionCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('xid', instance.xid);
  writeNotNull('guestId', instance.guestId);
  writeNotNull('xtranQueryCriteria', instance.xtranQueryCriteria?.toJson());
  writeNotNull('managingStoreId', instance.managingStoreId);
  writeNotNull('queryLinkedInfo', instance.queryLinkedInfo);
  return val;
}

QueryTransactionResponse _$QueryTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    QueryTransactionResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => GenTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QueryTransactionResponseToJson(
        QueryTransactionResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
    };

UpdateTransactionCommand _$UpdateTransactionCommandFromJson(
        Map<String, dynamic> json) =>
    UpdateTransactionCommand(
      xidToDelete: json['xidToDelete'] as int?,
      xtran: json['xtran'] == null
          ? null
          : GenTransaction.fromJson(json['xtran'] as Map<String, dynamic>),
      managingStoreId: json['managingStoreId'] as int?,
    );

Map<String, dynamic> _$UpdateTransactionCommandToJson(
    UpdateTransactionCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('xidToDelete', instance.xidToDelete);
  writeNotNull('xtran', instance.xtran?.toJson());
  writeNotNull('managingStoreId', instance.managingStoreId);
  return val;
}

OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) => OrderDetails(
      orderTime: DateTime.parse(json['orderTime'] as String),
      orderContent: json['orderContent'] as String,
      amount: (json['amount'] as num).toDouble(),
      storeId: json['storeId'] as int,
    );

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'orderTime': instance.orderTime.toIso8601String(),
      'orderContent': instance.orderContent,
      'amount': instance.amount,
      'storeId': instance.storeId,
    };

XtranLinkedInfo _$XtranLinkedInfoFromJson(Map<String, dynamic> json) =>
    XtranLinkedInfo(
      user: json['user'] == null
          ? null
          : GenUser.fromJson(json['user'] as Map<String, dynamic>),
      store: json['store'] == null
          ? null
          : GenStore.fromJson(json['store'] as Map<String, dynamic>),
      guest: json['guest'] == null
          ? null
          : GenGuest.fromJson(json['guest'] as Map<String, dynamic>),
      redeemPolicy: json['redeemPolicy'] == null
          ? null
          : GenRedeemPolicy.fromJson(
              json['redeemPolicy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$XtranLinkedInfoToJson(XtranLinkedInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user', instance.user?.toJson());
  writeNotNull('store', instance.store?.toJson());
  writeNotNull('guest', instance.guest?.toJson());
  writeNotNull('redeemPolicy', instance.redeemPolicy?.toJson());
  return val;
}

GenTransaction _$GenTransactionFromJson(Map<String, dynamic> json) =>
    GenTransaction(
      uid: json['uid'] as int?,
      guestId: json['guestId'] as int?,
      storeId: json['storeId'] as int?,
      description: json['description'] as String?,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      points: json['points'] as int,
      time: DateTime.parse(json['time'] as String),
      policyId: json['policyId'] as int?,
    )
      ..xid = json['xid'] as int?
      ..orderDetails = json['orderDetails'] == null
          ? null
          : OrderDetails.fromJson(json['orderDetails'] as Map<String, dynamic>)
      ..linkedInfo = json['linkedInfo'] == null
          ? null
          : XtranLinkedInfo.fromJson(
              json['linkedInfo'] as Map<String, dynamic>);

Map<String, dynamic> _$GenTransactionToJson(GenTransaction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('xid', instance.xid);
  writeNotNull('uid', instance.uid);
  writeNotNull('guestId', instance.guestId);
  writeNotNull('storeId', instance.storeId);
  val['time'] = instance.time.toIso8601String();
  writeNotNull('description', instance.description);
  val['type'] = _$TransactionTypeEnumMap[instance.type]!;
  val['points'] = instance.points;
  writeNotNull('policyId', instance.policyId);
  writeNotNull('orderDetails', instance.orderDetails?.toJson());
  writeNotNull('linkedInfo', instance.linkedInfo?.toJson());
  return val;
}

const _$TransactionTypeEnumMap = {
  TransactionType.orderCompleted: 'orderCompleted',
  TransactionType.storeGift: 'storeGift',
  TransactionType.pointsRedeem: 'pointsRedeem',
};

QueryRedeemPolicyCommand _$QueryRedeemPolicyCommandFromJson(
        Map<String, dynamic> json) =>
    QueryRedeemPolicyCommand(
      redeemPolicyQueryCriteria: json['redeemPolicyQueryCriteria'] == null
          ? null
          : GenRedeemPolicy.fromJson(
              json['redeemPolicyQueryCriteria'] as Map<String, dynamic>),
      policyId: json['policyId'] as int?,
    );

Map<String, dynamic> _$QueryRedeemPolicyCommandToJson(
    QueryRedeemPolicyCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('policyId', instance.policyId);
  writeNotNull('redeemPolicyQueryCriteria',
      instance.redeemPolicyQueryCriteria?.toJson());
  return val;
}

QueryRedeemPolicyResponse _$QueryRedeemPolicyResponseFromJson(
        Map<String, dynamic> json) =>
    QueryRedeemPolicyResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => GenRedeemPolicy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QueryRedeemPolicyResponseToJson(
        QueryRedeemPolicyResponse instance) =>
    <String, dynamic>{
      'result': instance.result.map((e) => e.toJson()).toList(),
    };

UpdateRedeemPolicyCommand _$UpdateRedeemPolicyCommandFromJson(
        Map<String, dynamic> json) =>
    UpdateRedeemPolicyCommand(
      policyIdToDelete: json['policyIdToDelete'] as int?,
      redeemPolicy: json['redeemPolicy'] == null
          ? null
          : GenRedeemPolicy.fromJson(
              json['redeemPolicy'] as Map<String, dynamic>),
      assignPassword: json['assignPassword'] as bool?,
    );

Map<String, dynamic> _$UpdateRedeemPolicyCommandToJson(
    UpdateRedeemPolicyCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('policyIdToDelete', instance.policyIdToDelete);
  writeNotNull('redeemPolicy', instance.redeemPolicy?.toJson());
  writeNotNull('assignPassword', instance.assignPassword);
  return val;
}

GenerateCodeCommand _$GenerateCodeCommandFromJson(Map<String, dynamic> json) =>
    GenerateCodeCommand(
      generateForRedeemPolicyId: json['generateForRedeemPolicyId'] as int?,
    );

Map<String, dynamic> _$GenerateCodeCommandToJson(GenerateCodeCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('generateForRedeemPolicyId', instance.generateForRedeemPolicyId);
  return val;
}

GenerateCodeResponse _$GenerateCodeResponseFromJson(
        Map<String, dynamic> json) =>
    GenerateCodeResponse(
      code: json['code'] as String,
    );

Map<String, dynamic> _$GenerateCodeResponseToJson(
        GenerateCodeResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
    };

RedeemForCodeCommand _$RedeemForCodeCommandFromJson(
        Map<String, dynamic> json) =>
    RedeemForCodeCommand(
      code: json['code'] as String,
      managingStoreId: json['managingStoreId'] as int,
    );

Map<String, dynamic> _$RedeemForCodeCommandToJson(
        RedeemForCodeCommand instance) =>
    <String, dynamic>{
      'code': instance.code,
      'managingStoreId': instance.managingStoreId,
    };

GenRedeemCode _$GenRedeemCodeFromJson(Map<String, dynamic> json) =>
    GenRedeemCode(
      code: json['code'] as String,
      guestId: json['guestId'] as int,
      policyId: json['policyId'] as int,
    );

Map<String, dynamic> _$GenRedeemCodeToJson(GenRedeemCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'guestId': instance.guestId,
      'policyId': instance.policyId,
    };

GenRedeemPolicy _$GenRedeemPolicyFromJson(Map<String, dynamic> json) =>
    GenRedeemPolicy(
      policyId: json['policyId'] as int?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      createdByUid: json['createdByUid'] as int?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      perGuestQuota: json['perGuestQuota'] as int?,
      pointsRequired: json['pointsRequired'] as int,
      imageUrl: json['imageUrl'] as String?,
      status:
          $enumDecodeNullable(_$RedeemPolicyStatusEnumMap, json['status']) ??
              RedeemPolicyStatus.normal,
      storeLimitType: $enumDecodeNullable(
              _$PolicyStoreLimitTypeEnumMap, json['storeLimitType']) ??
          PolicyStoreLimitType.notLimited,
      storeIds:
          (json['storeIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
    )..lastUpdated = json['lastUpdated'] == null
        ? null
        : DateTime.parse(json['lastUpdated'] as String);

Map<String, dynamic> _$GenRedeemPolicyToJson(GenRedeemPolicy instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('policyId', instance.policyId);
  writeNotNull('created', instance.created?.toIso8601String());
  writeNotNull('lastUpdated', instance.lastUpdated?.toIso8601String());
  writeNotNull('createdByUid', instance.createdByUid);
  writeNotNull('startTime', instance.startTime?.toIso8601String());
  writeNotNull('endTime', instance.endTime?.toIso8601String());
  val['title'] = instance.title;
  val['description'] = instance.description;
  writeNotNull('perGuestQuota', instance.perGuestQuota);
  val['pointsRequired'] = instance.pointsRequired;
  writeNotNull('imageUrl', instance.imageUrl);
  val['status'] = _$RedeemPolicyStatusEnumMap[instance.status]!;
  val['storeLimitType'] =
      _$PolicyStoreLimitTypeEnumMap[instance.storeLimitType]!;
  val['storeIds'] = instance.storeIds;
  return val;
}

const _$RedeemPolicyStatusEnumMap = {
  RedeemPolicyStatus.normal: 'normal',
  RedeemPolicyStatus.suspended: 'suspended',
};

const _$PolicyStoreLimitTypeEnumMap = {
  PolicyStoreLimitType.notLimited: 'notLimited',
  PolicyStoreLimitType.onlyApplicableToListed: 'onlyApplicableToListed',
  PolicyStoreLimitType.applicableExceptForListed: 'applicableExceptForListed',
};
