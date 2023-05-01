/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class MockMessageHandler extends ApiHandler {
  static late Box _mockMessageBox;
  static late Box _idxPhoneMockMessage;
  static late Box _idxEmailMockMessage;

  static Future<void> staticApiHandlerInit() async {
    _mockMessageBox = await Hive.openBox('gen_mockMessage');
    _idxPhoneMockMessage = await Hive.openBox('idx_phoneMockMessage');
    _idxEmailMockMessage = await Hive.openBox('idx_emailMockMessage');
    DbUtil.openedBoxes.addAll([_mockMessageBox, _idxPhoneMockMessage, _idxEmailMockMessage]);
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var queryMockMessageCommand = cmd.queryMockMessageCommand;
    if (queryMockMessageCommand != null) {
      await handleQueryMockMessageCommand(queryMockMessageCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  MockMessage ? getMockMessageById(int id) {
    var json = SharedApi.fixHiveJsonType(_mockMessageBox.get(id));
    if (json != null) {
      return MockMessage.fromJson(json);
    }
    return null;
  }

  Future<void> deleteMockMessage(int id) async {
    await du.logAndDelete('Deleting mock message', _mockMessageBox, id);
  }

  Future<void> sendMockMessage(MockMessage mockMessage) async {
    mockMessage.id ??= du.generateId(_mockMessageBox);
    //await _mockMessageBox.put(mockMessage.id!, mockMessage.toJson());
    await du.logAndPut('Update mockMessageBox', _mockMessageBox, mockMessage.id!, mockMessage.toJson());
    if (mockMessage.email != null) {
      List<int> ids = _idxEmailMockMessage.get(mockMessage.email!) ?? [];
      ids.add(mockMessage.id!);
      await _idxEmailMockMessage.put(mockMessage.email!, ids);
    }
    if (mockMessage.phone != null) {
      List<int> ids = _idxPhoneMockMessage.get(mockMessage.phone!) ?? [];
      ids.add(mockMessage.id!);
      await _idxPhoneMockMessage.put(mockMessage.phone!, ids);
    }
    for(var w in du._notificationHandler.waitingList) {
      for(var p in w.waitCmd.waitList) {
        if (p.type == NotificationType.mockMessageForPhone && mockMessage.phone == p.phone) {
          w.waitResp.eventfulIds.add(p.id);
        }
        else if (p.type == NotificationType.mockMessageForEmail && mockMessage.email == p.email) {
          w.waitResp.eventfulIds.add(p.id);
        }
      }
      if (w.waitResp.eventfulIds.isNotEmpty) {
        w.controller.add(0);
      }
    }
  }

  Future<void> handleQueryMockMessageCommand(QueryMockMessageCommand queryMockMessageCommand, ServerResponse resp, UserContext context) async {
    List<MockMessage> result = [];
    for(var query in queryMockMessageCommand.queryList) {
      if (query.queryType == MockMessageQueryType.server) {
        if (context.loggedIn != null && context.loggedIn!.fAdmin) {
          for (var json in _mockMessageBox.values) {
            result.add(MockMessage.fromJson(SharedApi.fixHiveJsonType(json)));
          }
        } else {
          throw ServerApiException(
              type: ServerResponseType.error,
              code: ServerResponseCode.insufficientPrivilegeError);
        }
      } else if (query.queryType ==
          MockMessageQueryType.phone) {
        var phone = query.phone;
        if (phone == null) {
          throw ServerApiException(
              type: ServerResponseType.error,
              code: ServerResponseCode.dataValidationError);
        }
        List<int> ids = _idxPhoneMockMessage.get(phone) ?? [];
        for (var id in ids) {
          var m = getMockMessageById(id);
          if (m != null) {
            result.add(m);
          }
        }
      } else if (query.queryType == MockMessageQueryType.email) {
        var email = query.email;
        if (email == null) {
          throw ServerApiException(
              type: ServerResponseType.error,
              code: ServerResponseCode.dataValidationError);
        }
        List<int> ids = _idxEmailMockMessage.get(email) ?? [];
        for (var id in ids) {
          var m = getMockMessageById(id);
          if (m != null) {
            result.add(m);
          }
        }
      } else {
        throw UnimplementedError();
      }
    } // for
    result.sort((b, a) => a.time.compareTo(b.time));
    resp.queryMockMessageResponse =
        QueryMockMessageResponse(result: result);
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final queryMockMessageCommand = cmd.queryMockMessageCommand;
    final updateMockMessageCommand = cmd.updateMockMessageCommand;
    if (queryMockMessageCommand != null) {
      await handleQueryMockMessageCommand(queryMockMessageCommand, resp, context);
    }
    else if (updateMockMessageCommand != null) {
      await handleUpdateMockMessageCommand(updateMockMessageCommand, resp);
    }
    else {
      return false;
    }
    return true;
  }

  Future<void> handleUpdateMockMessageCommand(UpdateMockMessageCommand updateMockMessageCommand, ServerResponse resp) async {
    var idToDelete = updateMockMessageCommand.idToDelete;
    if (idToDelete != null) {
      await deleteMockMessage(idToDelete);
    }
    else {
      throw UnimplementedError();
    }
  }
}

class NotificationWaitingRec {
  WaitForNotificationCommand waitCmd;
  WaitForNotificationResponse waitResp;
  StreamController<int> controller;
  NotificationWaitingRec({
    required this.controller,
    required this.waitCmd,
    required this.waitResp
  });
}

class NotificationHandler extends ApiHandler {
  List<NotificationWaitingRec> waitingList = [];

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    return false;
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var waitCmd = cmd.waitForNotificationCommand;
    var waitResp = WaitForNotificationResponse(eventfulIds: []);
    if (waitCmd != null) {
      int waitSeconds = max(waitCmd.waitSeconds, 30);
      var rec = NotificationWaitingRec(
          controller: StreamController<int>(),
          waitCmd: waitCmd,
          waitResp: waitResp);
      waitingList.add(rec);
      await rec.controller.stream.first.timeout(
          Duration(seconds: waitSeconds), onTimeout: ()=>0);
      rec.controller.close();
      waitingList.remove(rec);
      resp.waitForNotificationResponse = waitResp;
    }
    else {
      return false;
    }
    return true;
  }
}

