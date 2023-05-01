/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';

part 'protocol.g.dart';
part 'protocol_parts/server_top_level.dart';
part 'protocol_parts/store_commands.dart';
part 'protocol_parts/user_commands.dart';
part 'protocol_parts/guest_commands.dart';
part 'protocol_parts/bind_account_commands.dart';
part 'protocol_parts/mock_message_commands.dart';
part 'protocol_parts/transaction_commands.dart';
part 'protocol_parts/redeem_policy_commands.dart';
part 'protocol_parts/server_error_handling.dart';

class BasicData {
  static const rootEmail = 'root@example.com';
  static const rootFullName = 'Root';
  static const rootPhone = '000-000-0000';
  static const rootDefaultPasswordPlain = 'ZBuTzghq5tJ';
  static const updatedDefaultPasswordPlain = 'PY5pJ3bvG3Ye';
}

class SharedApi {
  static final zeroTime = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
  // static final int intMaxValue = 9223372036854775807;
  static final int intMaxValue =
      9007199254740991; // in order to be compatible also with Web
  static final _encryptKey = 'cLqyANrukrgQJyr/YrI+qw==';

  static String encryptedDigest(String message) {
    List<int> messageBytes = utf8.encode(message);
    List<int> key = base64.decode(_encryptKey);
    Hmac hmac = Hmac(sha256, key);
    Digest digest = hmac.convert(messageBytes);
    return base64.encoder.convert(digest.bytes);
  }

  static String actuatedHashedPassword(
      String userName, String hashedPassword, DateTime time) {
    String combinedStr = '$userName:$hashedPassword:$time';
    return encryptedDigest(combinedStr);
  }

  static dynamic fixHiveJsonType(dynamic json) {
    if (json is Map<dynamic, dynamic>) {
      json = json.cast<String, dynamic>();
      for(var entry in json.entries) {
        json[entry.key] = fixHiveJsonType(entry.value);
      }
    }
    else if (json is List<dynamic>) {
      for(int i=0;i<json.length;i++) {
        json[i] = fixHiveJsonType(json[i]);
      }
    }
    return json;
  }
}

abstract class ServerConnection {
  Future<ServerResponse> sendServerCommand(ServerCommand cmd);
  void logout();
  void shutdown() {}
  ServerConnection createAnotherConnection();

  Future<LoginResponse> login(LoginCommand loginCommand) async {
    var cmd = ServerCommand();
    cmd.loginCommand = loginCommand;
    ServerResponse resp = await sendServerCommand(cmd);
    return resp.loginResponse!;
  }

  Future<void> changePassword(ChangePasswordCommand changePasswordCommand) async {
    var cmd = ServerCommand();
    cmd.changePasswordCommand = changePasswordCommand;
    await sendServerCommand(cmd);
  }

  Future<DbPropValue?> getProp(String name) async {
    var cmd = ServerCommand();
    var getprop = GetPropCommand(name);
    cmd.getPropCommand = getprop;
    ServerResponse resp = await sendServerCommand(cmd);
    return resp.getPropResult!.prop;
  }

  Future<void> updateProp(DbPropValue prop) async {
    var cmd = ServerCommand();
    var upd = UpdatePropCommand(prop);
    cmd.updatePropCommand = upd;
    await sendServerCommand(cmd);
  }

  Future<UpdateRecordResponse> updateStore(GenStore store) async {
    var cmd = ServerCommand();
    var upd = UpdateStoreCommand(store: store);
    cmd.updateStoreCommand = upd;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.updateRecordResponse!;
  }

  Future<int> createStore(GenStore store) async {
    var updateRecordResponse = await updateStore(store);
    return updateRecordResponse.newId!;
  }

  Future<GenUser> getUserById(int uid) async {
    var cmd = ServerCommand();
    var query = QueryUserCommand(uid: uid);
    cmd.queryUserCommand = query;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.queryUserResponse!.result[0];
  }

  Future<GenStore> getStoreById(int storeId) async {
    var cmd = ServerCommand();
    var query = QueryStoreCommand(storeId: storeId);
    cmd.queryStoreCommand = query;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.queryStoreResponse!.result[0];
  }

  Future<UpdateRecordResponse> updateUser(GenUser user) async {
    var cmd = ServerCommand();
    var upd = UpdateUserCommand(user: user);
    cmd.updateUserCommand = upd;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.updateRecordResponse!;
  }

  Future<int> createUser(GenUser user) async {
    var updateRecordResponse = await updateUser(user);
    return updateRecordResponse.newId!;
  }

  Future<UpdateRecordResponse> updateGuest(GenGuest guest) async {
    var cmd = ServerCommand();
    var upd = UpdateGuestCommand(guest: guest);
    cmd.updateGuestCommand = upd;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.updateRecordResponse!;
  }

  Future<int> createGuest(GenGuest guest) async {
    var updateRecordResponse = await updateGuest(guest);
    return updateRecordResponse.newId!;
  }

  Future<UpdateRecordResponse> updateTransaction(GenTransaction tran) async {
    var cmd = ServerCommand();
    var upd = UpdateTransactionCommand(xtran: tran);
    cmd.updateTransactionCommand = upd;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.updateRecordResponse!;
  }

  Future<int> createTransaction(GenTransaction tran) async {
    var updateRecordResponse = await updateTransaction(tran);
    return updateRecordResponse.newId!;
  }

  Future<List<GenTransaction>> getTransactionListByGuestId(int guestId) async {
    var cmd = ServerCommand();
    var upd = QueryTransactionCommand(guestId: guestId);
    cmd.queryTransactionCommand = upd;
    var serverResponse = await sendServerCommand(cmd);
    return serverResponse.queryTransactionResponse!.result;
  }
}

class HttpServerConnection extends ServerConnection {
  ChannelContext? channel;
  HttpClient client = HttpClient();
  Uri serverApiUrl;

  HttpServerConnection(this.serverApiUrl);

  @override
  void logout() {
    channel = null;
  }

  @override
  Future<ServerResponse> sendServerCommand(ServerCommand cmd) async {
    cmd.channel ??= channel;
    HttpClientRequest request = await client.postUrl(serverApiUrl);
    request.write(jsonEncode(cmd.toJson()));
    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    ServerResponse resp = ServerResponse.fromJson(jsonDecode(stringData));
    if (resp.type == ServerResponseType.ok) {
      var loginResponse = resp.loginResponse;
      if (loginResponse!=null) {
        channel = loginResponse.channel;
      }
      return resp;
    }
    else {
      throw ServerException(type: resp.type, code: resp.code);
    }
  }

  @override
  ServerConnection createAnotherConnection() {
    return HttpServerConnection(serverApiUrl);
  }
}

@JsonSerializable()
class ChannelContext {
  String cid;
  ChannelContext(this.cid);
  factory ChannelContext.fromJson(Map<String, dynamic> json) =>
      _$ChannelContextFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelContextToJson(this);
}

@JsonSerializable()
class ImageSet {
  final String searchUrl;
  final List<String> imageList;
  const ImageSet({
    required this.searchUrl,
    required this.imageList});
  factory ImageSet.fromJson(Map<String, dynamic> json) =>
      _$ImageSetFromJson(json);
  Map<String, dynamic> toJson() => _$ImageSetToJson(this);
}

@JsonSerializable()
class ImageDefinitions {
  final ImageSet coffeeShop;
  final ImageSet drinks;
  final ImageSet coffee;
  const ImageDefinitions({
    required this.coffeeShop,
    required this.drinks,
    required this.coffee});
  factory ImageDefinitions.fromJson(Map<String, dynamic> json) =>
      _$ImageDefinitionsFromJson(json);
  Map<String, dynamic> toJson() => _$ImageDefinitionsToJson(this);
}
