/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:convert';
import 'package:protocol/test_data.dart';
import 'client_state.dart';
import 'protocol.dart';
import 'package:logging/logging.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

Logger logger = Logger('server');

class DataTester {
  final clientStateKey = 'data_tester';

  ServerConnection conn;
  DbPropOfSetup? setup;
  var state = DataTesterState();
  Box? box;

  DataTester(this.conn);

  Future<void> saveState() async {
    logger.info('saveState(): state:${jsonEncode(state)}');
    await box!.put(clientStateKey, state.toJson());
  }

  Future<void> checkSetup({purge = false}) async {
    var box = await Hive.openBox('client');
    if (purge) {
      await box.clear();
    }
    this.box = box;
    var jsonState = SharedApi.fixHiveJsonType(box.get(clientStateKey));
    if (jsonState != null) {
      state = DataTesterState.fromJson(jsonState);
    }
    logger.info('checkSetup(): state:${jsonEncode(state)}');
    if (state.rootUser == null) { // perform change password
      await conn.login(createLoginCommand(SharedApi.encryptedDigest(BasicData.rootDefaultPasswordPlain)));
      await conn.changePassword(ChangePasswordCommand(
          SharedApi.encryptedDigest(BasicData.rootDefaultPasswordPlain),
          SharedApi.encryptedDigest(BasicData.updatedDefaultPasswordPlain)));
      state.rootUser = BasicData.rootEmail;
      await saveState();
    }
    else {
      await conn.login(createLoginCommand(SharedApi.encryptedDigest(BasicData.updatedDefaultPasswordPlain)));
    }
    if (state.dataVersion < 1) {
      await inputBasicDataSet();
      state.dataVersion = 1;
      await saveState();
    }
  }

  Future<void> inputBasicDataSet() async {
    var users = UserData();
    var guests = GuestData();
    var stores = StoreData();
    /*var brynnId =*/ await conn.createUser(users.brynn.copyWith());
    var lazarId = await conn.createUser(users.lazar.copyWith());
    var tersinaId = await conn.createUser(users.tersina.copyWith());
    var madelineId = await conn.createUser(users.madeline.copyWith());
    var joshId = await conn.createUser(users.josh.copyWith());
    var krystinId = await conn.createUser(users.krystin.copyWith());
    var adrianaId = await conn.createUser(users.adriana.copyWith());
    var toiboidId = await conn.createUser(users.toiboid.copyWith());
    var oreleeId = await conn.createUser(users.orelee.copyWith());
    var yalondaId = await conn.createUser(users.yalonda.copyWith());
    // await conn.createUser(GenUser(email: '', fullName: '', phone: ''));
    stores.dynazzy
      ..users = [
        StoreUser(uid: lazarId, role: UserRoleAtStore.manager),
        StoreUser(uid: tersinaId, role: UserRoleAtStore.staff),
        StoreUser(uid: madelineId, role: UserRoleAtStore.staff),
        ]
      ..usersChanged = true;
    var dynazzyId = await conn.createStore(stores.dynazzy.copyWith());
    stores.zoonoodle
      ..users = [
        StoreUser(uid: madelineId, role: UserRoleAtStore.manager),
        StoreUser(uid: joshId, role: UserRoleAtStore.staff),
        StoreUser(uid: krystinId, role: UserRoleAtStore.staff),
        StoreUser(uid: adrianaId, role: UserRoleAtStore.staff),
        StoreUser(uid: tersinaId, role: UserRoleAtStore.staff),
      ]
      ..usersChanged = true;
    await conn.createStore(stores.zoonoodle.copyWith());
    stores.centidel
      ..users = [
        StoreUser(uid: toiboidId, role: UserRoleAtStore.manager),
        StoreUser(uid: oreleeId, role: UserRoleAtStore.manager),
        StoreUser(uid: yalondaId, role: UserRoleAtStore.staff),
        StoreUser(uid: adrianaId, role: UserRoleAtStore.staff),
        StoreUser(uid: madelineId, role: UserRoleAtStore.staff),
      ]
      ..usersChanged = true;
    await conn.createStore(stores.centidel.copyWith());
    await conn.getUserById(madelineId);
    var dynazzy = await conn.getStoreById(dynazzyId);
    dynazzy.users = [];
    await conn.updateStore(dynazzy);
    await conn.getUserById(madelineId);
    await conn.sendServerCommand(ServerCommand(
      resetPasswordCommand: ResetPasswordCommand(
        assignPasswordByAdmin: AssignPasswordByAdmin(
          userEmail: users.lazar.email,
          passwordPlain: users.lazar.plainPassword!
        )
      )
    ));
    var resetPasswordList = users.getList();
    for(var rp in resetPasswordList) {
      await conn.sendServerCommand(ServerCommand(
          resetPasswordCommand: ResetPasswordCommand(
              assignPasswordByAdmin: AssignPasswordByAdmin(
                  userEmail: rp.email,
                  passwordPlain: rp.plainPassword!
              )
          )
      ));
    }
    ServerConnection conn2 = conn.createAnotherConnection();
    DateTime now = DateTime.now();
    await conn2.login(LoginCommand(
        email: users.lazar.email,
        actuatedHashedPassword:
            SharedApi.actuatedHashedPassword(users.lazar.email, SharedApi.encryptedDigest(users.lazar.plainPassword!), now),
        time: now)
    );

    final df = DateFormat('M/d/y');
    var missyId = await conn.createGuest(guests.missy);
    var mikaelId = await conn.createGuest(guests.mikael);
    var elliottId = await conn.createGuest(guests.elliott);
    var gavanId = await conn.createGuest(guests.gavan);
    // id	full_name	email	gender	phone	birthday
    // 11	Sher Havercroft	shavercrofta@mozilla.com	Female	388-805-4423	10/31/1983
    // 12	Galvan Grigoroni	ggrigoronib@acquirethisname.com	Polygender	602-669-0963
    // 13	Jayme Tebbut	jtebbutc@nifty.com	Female	989-328-1129	2/4/1998
    // 14	Sophronia Scanes	sscanesd@admin.ch	Female	320-459-1499	9/26/2002
    // 16	Helaina Birrell	hbirrellf@fastcompany.com	Female	499-792-6325	1/28/1977
    // 17	Bliss Mathiassen	bmathiasseng@etsy.com	Female	467-225-9710	2/6/1986
    // 18	Nat O' Gara	noh@blogs.com	Polygender	216-603-8943	8/18/2004
    // 19	Rube Dishmon	rdishmoni@alexa.com	Male	939-307-2201	12/9/1988
    // 20	Jacquelin McGairl	jmcgairlj@seesaa.net	Female	744-950-7092	12/10/1982
    // 21	Kirk Jakubowski	kjakubowskik@cnbc.com	Male	178-679-5950	9/1/2003
    await conn.createTransaction(GenTransaction(guestId: missyId, storeId: dynazzyId, type: TransactionType.orderCompleted, points: 20, time: df.parse('2/3/2022')));
    await conn.createTransaction(GenTransaction(guestId: missyId, storeId: dynazzyId, type: TransactionType.orderCompleted, points: 30, time: df.parse('2/4/2022')));
    await conn.createTransaction(GenTransaction(guestId: mikaelId, storeId: dynazzyId, type: TransactionType.orderCompleted, points: 40, time: df.parse('2/5/2022')));
    await conn.createTransaction(GenTransaction(guestId: missyId, storeId: dynazzyId, type: TransactionType.orderCompleted, points: 50, time: df.parse('2/6/2022')));
    await conn.createTransaction(GenTransaction(guestId: elliottId, storeId: dynazzyId, type: TransactionType.storeGift, uid: tersinaId, points: 50, time: df.parse('2/6/2022')));
    await conn.createTransaction(GenTransaction(guestId: gavanId, storeId: dynazzyId, type: TransactionType.storeGift, uid: tersinaId, points: 50, time: df.parse('2/7/2022')));
    await conn.getTransactionListByGuestId(missyId);

    var redeemPolicies = getRedeemPolicies();
    for(var policy in redeemPolicies) {
      await conn.sendServerCommand(ServerCommand(
          updateRedeemPolicyCommand: UpdateRedeemPolicyCommand(
              redeemPolicy: policy
          )
      ));
    }
  }

  Future<void> inputDataSet4() async {
    conn.logout();
    String email = 'lbonifant0@wikimedia.org';
    await conn.sendServerCommand(
        ServerCommand(resetPasswordCommand:
            ResetPasswordCommand(passwordReassignment:
                PasswordReassignmentRec(
                  identityType: IdentityType.user,
                  resetPasswordType: ResetPasswordType.email,
                  email: email,
                )
            )
        )
    );
    ServerResponse resp;
    resp = await conn.sendServerCommand(ServerCommand(queryMockMessageCommand:
        QueryMockMessageCommand(
        queryList: [MockMessageQuery(
              queryType: MockMessageQueryType.email,
              email: email
          )]
        )
    ));
    var result = resp.queryMockMessageResponse!.result;
    var firstMsg = result[0];
    if (firstMsg.email != email) throw DataBuilderException('Email not match: ${firstMsg.email}');
    resp = await conn.sendServerCommand(ServerCommand(resetPasswordCommand:
        ResetPasswordCommand(
          enteredAuthKey: firstMsg.authKey
        )
    ));
    var generatedPassword = resp.resetPasswordResponse!.generatedPassword!;
    var hashedPassword = SharedApi.encryptedDigest(generatedPassword);
    DateTime time = DateTime.now();
    await conn.login(LoginCommand(email: email, actuatedHashedPassword: SharedApi.actuatedHashedPassword(email, hashedPassword, time), time: time));
  }

  Future<void> performTest() async {
    await performTestOnGuestRegister();
    await performTestOnRedeemPolicy();
  }

  Future<void> performTestOnRedeemPolicy() async {
    await conn.sendServerCommand(ServerCommand(
      queryRedeemPolicyCommand: QueryRedeemPolicyCommand()
    ));
  }

  Future<void> performTestOnGuestRegister() async {
    // id	full_name	email	gender	phone	birthday
    // 4	Ritchie Johananov	rjohananov3@tripadvisor.com	Male	225-885-3598	1/25/2004
    var guests = GuestData();
    var newConn = conn.createAnotherConnection();
    await newConn.sendServerCommand(ServerCommand(
        registerAccountCommand: RegisterAccountCommand(
            type: IdentityType.guest,
            phone: guests.ritchie.phone
       )
    ));
    var resp = await newConn.sendServerCommand(ServerCommand(
        queryMockMessageCommand: QueryMockMessageCommand(
            queryList: [
              MockMessageQuery(
                  queryType: MockMessageQueryType.phone,
                  phone: guests.ritchie.phone)
            ]
        )
    ));
    MockMessage msg = resp.queryMockMessageResponse!.result[0];
    resp = await newConn.sendServerCommand(ServerCommand(
        bindAccountCommand: BindAccountCommand(
            enteredOtpCode: msg.otpCode,
            action: BindAccountCommandAction.query,
        )
    ));

    var guest = resp.bindAccountResponse!.guest;
    guest ??= GenGuest(
      fullName: guests.ritchie.fullName,
      phone: guests.ritchie.phone,
      birthday: guests.ritchie.birthday,
      gender: guests.ritchie.gender,
      email: guests.ritchie.email
    );
    guest.hashedPassword = SharedApi.encryptedDigest(guests.ritchie.plainPassword!);
    await newConn.sendServerCommand(ServerCommand(
        bindAccountCommand: BindAccountCommand(
            enteredOtpCode: msg.otpCode,
            action: BindAccountCommandAction.update,
            guest: guest,
            )
        )
    );
    DateTime now = DateTime.now();
    await newConn.sendServerCommand(ServerCommand(
      guestLoginCommand: GuestLoginCommand(
          phone: guests.ritchie.phone,
          actuatedHashedPassword: SharedApi.actuatedHashedPassword(guests.ritchie.phone, guest.hashedPassword!, now),
          time: now)
    ));
  }

  Future<void> loadSetup() async {
    var prop = await conn.getProp('setup');
    if (prop == null) {
      setup = DbPropOfSetup();
    }
    else {
      setup = prop.setup!;
    }
  }

  Future<void> testProp() async {
    var cmd = ServerCommand();
    var upd = UpdatePropCommand(DbPropValue(name: 'setup', setup: DbPropOfSetup(rootUser: 'my_root')));
    cmd.updatePropCommand = upd;
    await conn.sendServerCommand(cmd);
  }

  Future<void> updateSetup() async {
    await conn.updateProp(DbPropValue(name:'setup', setup: setup!));
  }

  LoginCommand createLoginCommand(String hashedPassword) {
    DateTime time = DateTime.now();
    return LoginCommand(
        email: BasicData.rootEmail,
        actuatedHashedPassword: SharedApi.actuatedHashedPassword(BasicData.rootEmail, hashedPassword, time),
        time: time
    );
  }

  Future<void> performDefaultLogin() async {
    String hashedPassword = SharedApi.encryptedDigest(BasicData.rootDefaultPasswordPlain);
    DateTime time = DateTime.now();
    LoginCommand loginCommand = LoginCommand(
        email: BasicData.rootEmail,
        actuatedHashedPassword: SharedApi.actuatedHashedPassword(BasicData.rootEmail, hashedPassword, time),
        time: time
    );
    await conn.login(loginCommand);
  }
}

class DataBuilderException implements Exception {
  final dynamic message;

  DataBuilderException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "DataBuilderException: $message";
  }
}


