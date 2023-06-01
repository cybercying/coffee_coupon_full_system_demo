/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';
import 'dart:math' show Random, max;

import 'package:protocol/protocol.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:hive/hive.dart';

part 'api_parts/user_api_handler.dart';
part 'api_parts/guest_api_handler.dart';
part 'api_parts/bind_account_handler.dart';
part 'api_parts/store_api_handler.dart';
part 'api_parts/transaction_api_handler.dart';
part 'api_parts/mock_message_handler.dart';
part 'api_parts/redeem_policy_handler.dart';

enum UserContextState {
  notExist,
  existing,
  needDelete,
}

abstract class UserChangeListener {
  // if user is null, then the change is the fact that it's deleted
  void onUserChanged(GenUser? user);
}

class LoggedInUser implements UserChangeListener {
  int uid;
  String email;
  bool fAdmin;
  DbUtil du;
  Set<int>? _cachedAccessibleUids;
  LoggedInUser({
    required this.du,
    required this.uid,
    required this.email,
    required this.fAdmin,
  });

  Set<int> getCachedAccessibleUids() {
    _cachedAccessibleUids ??= du._userApiHandler.getAccessibleUids(uid);
      return _cachedAccessibleUids!;
  }

  void initLoggedInUser() {
    du._userApiHandler.listenToUserChange(uid, this, true);
  }

  void prepareToBeRemoved() {
    du._userApiHandler.listenToUserChange(uid, this, false);
  }

  @override
  void onUserChanged(GenUser? user) {
    _cachedAccessibleUids = null;
  }

  @override
  String toString() {
    return 'LoggedInUser{uid: $uid, email: $email, fAdmin: $fAdmin, du: $du}';
  }
}

class LoggedInGuest {
  int guestId;
  String phone;
  LoggedInGuest({
    required this.guestId,
    required this.phone
  });
}

class UserContext {
  UserContextState state;
  LoggedInUser? loggedIn;
  LoggedInGuest? loggedInGuest;
  DateTime lastActivity = SharedApi.zeroTime;
  UserContext(this.state);

  void prepareToBeRemoved() {
    loggedIn?.prepareToBeRemoved();
  }

  @override
  String toString() {
    return 'UserContext{state: $state, loggedIn: $loggedIn, loggedInGuest: $loggedInGuest, lastActivity: $lastActivity}';
  }
}

String combinePath(Directory? dir, String path) {
  if (dir==null) {
    return path;
  }
  return '${dir.path}/$path';
}

class LocalServerConnection extends ServerConnection {
  ChannelContext? channel;
  DbUtil du;

  LocalServerConnection({required this.du});

  @override
  Future<ServerResponse> sendServerCommand(ServerCommand cmd) async {
    cmd.channel = channel;
    try {
      ServerResponse resp = await du.handleApiRequest(cmd);
      if (resp.type == ServerResponseType.ok) {
        var loginResponse = resp.loginResponse;
        var guestLoginResponse = resp.guestLoginResponse;
        if (loginResponse != null) {
          channel = loginResponse.channel;
        }
        else if (guestLoginResponse != null) {
          channel = guestLoginResponse.channel;
        }
        return resp;
      }
      else {
        throw ServerException(type: resp.type, code: resp.code);
      }
    }
    on ServerApiException catch(e) {
      throw ServerException(type: e.type, code: e.code);
    }
  }

  @override
  void logout() {
    channel = null;
  }

  @override
  ServerConnection createAnotherConnection() {
    return LocalServerConnection(du: du);
  }
}

class DbUtil {

  static Future<void> staticDeInit() async {
    await Hive.close();
    if (appender != null) {
      await appender!.dispose();
      appender = null;
    }
  }

  static RotatingFileAppender? appender;

  static List<Box> openedBoxes = [];

  static Future<void> staticInit({bool isWeb = false, Directory? dir}) async {
    Logger.root.level = Level.ALL;
    PrintAppender.setupLogging(stderrLevel: Level.ALL);
    if (!isWeb) {
      var logDir = combinePath(dir, 'log');
      await Directory(logDir).create();
      appender = RotatingFileAppender(baseFilePath: '$logDir/server.log');
      appender!.attachToLogger(Logger.root);
    }
    Logger logger = Logger('server');

    Hive.init(combinePath(dir,'.hive'));
    await PropApiHandler.staticApiHandlerInit();
    await UserApiHandler.staticApiHandlerInit();
    await StoreApiHandler.staticApiHandlerInit();
    await MockMessageHandler.staticApiHandlerInit();
    await PasswordReassignHandler.staticApiHandlerInit();
    await RegisterAccountHandler.staticApiHandlerInit();
    await GuestApiHandler.staticApiHandlerInit();
    await RedeemPolicyApiHandler.staticApiHandlerInit();
    await TransactionApiHandler.staticApiHandlerInit();

    var time = SharedApi.zeroTime;

    logger.info('hashed: ${SharedApi.encryptedDigest('hello world')}');
    logger.info('utc(0): $time, millis: ${time.microsecondsSinceEpoch}');
  }

  void info(Object msg) {
    logger.log(Level.INFO, msg);
  }

  void dbg(Object msg) {
    logger.fine(Level.FINE, msg);
  }

  void severe(Object msg, [Object? error, StackTrace? stackTrace]) {
    logger.severe(msg, error, stackTrace);
  }

  final _userApiHandler = UserApiHandler();
  final _storeApiHandler = StoreApiHandler();
  final _guestApiHandler = GuestApiHandler();
  final _transactionApiHandler = TransactionApiHandler();
  final _propApiHandler = PropApiHandler();
  final _pwdReassignHandler = PasswordReassignHandler();
  final _mockMessageHandler = MockMessageHandler();
  final _notificationHandler = NotificationHandler();
  final _registerAccountHandler = RegisterAccountHandler();
  final _redeemPolicyApiHandler = RedeemPolicyApiHandler();
  Timer? _contextCheckTimer;

  late List<ApiHandler> _apiHandlers;
  late List<ApiHandler> _apiHandlersPreLogin;
  late List<ApiHandler> _guestApiHandlers;

  Logger logger = Logger('server');
  Random random = Random.secure();
  final _contextMap = <String, UserContext>{};

  DbUtil() {
    _userApiHandler.du = this;
    _storeApiHandler.du = this;
    _guestApiHandler.du = this;
    _transactionApiHandler.du = this;
    _propApiHandler.du = this;
    _pwdReassignHandler.du = this;
    _mockMessageHandler.du = this;
    _notificationHandler.du = this;
    _registerAccountHandler.du = this;
    _redeemPolicyApiHandler.du = this;
    _apiHandlers = [_userApiHandler, _storeApiHandler, _guestApiHandler, _transactionApiHandler, _propApiHandler, _pwdReassignHandler, _mockMessageHandler, _notificationHandler, _redeemPolicyApiHandler];
    _apiHandlersPreLogin = [_userApiHandler, _pwdReassignHandler, _mockMessageHandler, _notificationHandler, _registerAccountHandler, _guestApiHandler];
    _guestApiHandlers = [_redeemPolicyApiHandler, _guestApiHandler, _storeApiHandler];
  }

  int generateId(Box box) {
    while (true) {
      int id = random.nextInt(1<<31);
      if (id > 0) {
        if (!box.containsKey(id)) {
          return id;
        }
      }
    }
  }

  int generateOtpCode() {
    return random.nextInt(900000) + 100000;
  }

  String generateRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<void> checkData() async {
    info('Checking data...');
    GenUser? root = _userApiHandler.getUserByEmail(BasicData.rootEmail);
    if (root == null) {
      var now = DateTime.now();
      info('Creating default root user...');
      root = GenUser(
          email: BasicData.rootEmail,
          fullName: BasicData.rootFullName,
          phone: BasicData.rootPhone,
          created: now,
          lastUpdated: now,
          hashedPassword:
              SharedApi.encryptedDigest(BasicData.rootDefaultPasswordPlain),
          fAdmin: true);
      await _userApiHandler.updateUser(root);
    }
  }

  Future<ServerResponse> handleApiRequest(ServerCommand cmd) async {
    try {
      //info('handleApiRequest(): ${cmd.toJson()}');
      ServerResponse resp = await _serverApiRequest(cmd);
      resp.type = ServerResponseType.ok;
      return resp;
    }
    on ServerApiException catch(e, s) {
      severe(e, s);
      return ServerResponse(type: e.type, code: e.code);
    }
    on UnimplementedError {
      return ServerResponse(type: ServerResponseType.error, code: ServerResponseCode.notImplemented);
    }
    catch(e, s) {
      severe(e, s);
      return ServerResponse(type: ServerResponseType.error, code: ServerResponseCode.internalServerError);
    }
  }

  static const maxIdleDuration = Duration(minutes: 10);
  static const checkIdleDuration = Duration(seconds: 30);

  void checkUserContext() {
    _contextCheckTimer = null;
    var now = DateTime.now();
    Set<String> removeSet = {};
    for(var entry in _contextMap.entries) {
      if (now.difference(entry.value.lastActivity) > maxIdleDuration) {
        entry.value.prepareToBeRemoved();
        log("auto logout for inactivity: ${entry.value}");
        removeSet.add(entry.key);
      }
    }
    _contextMap.removeWhere((key, value) => removeSet.contains(key));
    if (_contextMap.isNotEmpty) {
      _contextCheckTimer ??= Timer(checkIdleDuration, checkUserContext);
    }
  }

  Future<ServerResponse> _serverApiRequest(ServerCommand cmd) async {
    ServerResponse resp = ServerResponse(type: ServerResponseType.none);
    _contextCheckTimer ??= Timer(checkIdleDuration, checkUserContext);
    var context = UserContext(UserContextState.notExist);
    var channel = cmd.channel;
    if (channel != null) {
      var existingContext = _contextMap[channel.cid];
      if (existingContext != null) {
        context = existingContext;
      }
    }
    final now = DateTime.now();
    context.lastActivity = now;
    final loggedIn = context.loggedIn;
    final loggedInGuest = context.loggedInGuest;
    if (loggedIn == null && loggedInGuest == null) {
      bool valid = false;
      for(var handler in _apiHandlersPreLogin) {
        bool handled = await handler.handlePreLoginApiRequest(cmd, resp, context);
        if (handled) {
          valid = true;
          break;
        }
      }
      if (!valid) {
        throw ServerApiException(type: ServerResponseType.notAuthenticated);
      }
    }
    else if (loggedIn != null){
      bool valid = false;
      for(var handler in _apiHandlers) {
        bool handled = await handler.handleApiRequest(cmd, resp, context);
        if (handled) {
          valid = true;
          break;
        }
      }
      if (!valid) {
        throw ServerApiException.error(ServerResponseCode.unknownCommand);
      }
    }
    else if (loggedInGuest != null) {
      bool valid = false;
      for(var handler in _guestApiHandlers) {
        bool handled = await handler.handleGuestApiRequest(cmd, resp, context);
        if (handled) {
          valid = true;
          break;
        }
      }
      if (!valid) {
        throw ServerApiException.error(ServerResponseCode.unknownCommand);
      }
    }
    else {
      throw ServerApiException.error(ServerResponseCode.illegalOperationForCurrentState);
    }
    return resp;
  }

  Future<void> logAndPut(
      String msg, Box box, dynamic key, dynamic value) async {
    info('$msg, putting $key to box ${box.name}: $value');
    await box.put(key, value);
  }

  Future<void> logAndDelete(String msg, Box box, dynamic key) async {
    info('$msg, deleting $key from box ${box.name}');
    await box.delete(key);
  }

  Future<void> logAndUpdateList(
      String msg, Box box, dynamic key, List value) async {
    info('$msg, putting $key to box ${box.name}: $value');
    if (value.isEmpty) {
      box.delete(key);
    }
    else {
      await box.put(key, value);
    }
  }

  Future<void> resetDatabase() async {
    int count = 0;
    for(var box in openedBoxes) {
      count += await box.clear();
    }
    log('resetDatabase(): cleared $count records.');
    await checkData();
  }
}

abstract class ApiHandler {
  late DbUtil du;
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context);
  Future<bool> handleGuestApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    return false;
  }
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    return false;
  }
}

class PropApiHandler extends ApiHandler {
  static late Box _propBox;

  static Future<void> staticApiHandlerInit() async {
    _propBox = await Hive.openBox('prop');
    DbUtil.openedBoxes.add(_propBox);
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var loggedIn = context.loggedIn!;
    final getPropGroupCommand = cmd.getPropCommand;
    final updatePropCommand = cmd.updatePropCommand;
    if (getPropGroupCommand != null && loggedIn.fAdmin) {
      var json = SharedApi.fixHiveJsonType(_propBox.get(getPropGroupCommand.name));
      resp.type = ServerResponseType.ok;
      var getPropGroupResult =
      GetPropResult(DbPropValue.fromJsonOrNull(json));
      resp.getPropResult = getPropGroupResult;
    } else if (updatePropCommand != null && loggedIn.fAdmin) {
      DbPropValue prop = updatePropCommand.prop;
      await du.logAndPut('Updating prop', _propBox, prop.name, prop.toJson());
      resp.type = ServerResponseType.ok;
    }
    else {
      return false;
    }
    return true;
  }
}

