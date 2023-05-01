/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:cached_network_image/cached_network_image.dart';
import '../app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';

import '../ui_shared.dart';
import 'barcode_ui.dart' show CouponRedeemBarcodeScreen;
import 'guest_app.dart';
import 'guest_app_ui.dart';

class CouponListScreen extends StatelessWidget {
  final bool isFavoriteList;
  const CouponListScreen({Key? key, required this.isFavoriteList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GuestApp guestApp = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text(isFavoriteList ? 'guestApp.favoriteCouponList'.tr : 'guestApp.couponList'.tr),
        actions: getAppbarActions(),
      ),
      bottomNavigationBar: GuestAppNavigationBar(currentIndex: isFavoriteList ? 1 : 0),
      body: ListView(
        children: [
          isFavoriteList ? const SizedBox(height: 20) : Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Text(
              'guestApp.greetingLine'.trParams({'guestName': guestApp.guestAccount.value.fullName}),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GetBuilder<GuestApp>(
                id: isFavoriteList ? 'redeemPolicyQueryResultFavorite' : 'redeemPolicyQueryResult',
                builder: (guestApp) {
                  List<Widget> list = [];
                  for(var policy in guestApp.redeemPolicyQueryResult) {
                    if (!isFavoriteList || (isFavoriteList && guestApp.favoriteMap[policy.policyId!]!.value)) {
                      list.add(CouponCard(policy: policy));
                    }
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: list,
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}

class StoreListScreen extends StatelessWidget {
  const StoreListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GuestApp guestApp = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('guestApp.stores'.tr),
        actions: getAppbarActions(),
      ),
      bottomNavigationBar: const GuestAppNavigationBar(currentIndex: 2),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for(var store in guestApp.storeQueryResult)
                  CoolCard(
                      title: store.name,
                      imageUrl: store.imageUrl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRichLine('Address: ', store.address),
                          buildRichLine('Phone: ', store.phone),
                        ]
                      )
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  RichText buildRichLine(String field, String value) {
    return RichText(
        text: TextSpan(
            style: Get.textTheme.bodyMedium,
            children: [
              TextSpan(text: field, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value)
            ]
        )
    );
  }
}

const defaultCouponImage = 'https://media.istockphoto.com/photos/cup-of-cafe-latte-with-coffee-beans-and-cinnamon-sticks-picture-id505168330?b=1&k=20&m=505168330&s=170667a&w=0&h=jJTePtpYZLR3M2OULX5yoARW7deTuAUlwpAoS4OriJg=';

class CoolCard extends StatelessWidget {
  final Function()? onTap;
  final String? imageUrl;
  final String title;
  final Widget child;
  final String? tagText;
  const CoolCard({
    Key? key,
    this.onTap,
    this.imageUrl,
    required this.title,
    required this.child,
    this.tagText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(3, 5),
            ),
          ],
          color: appSettings.appTheme.couponCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        //width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.all(15),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3 - 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              imageUrl ?? defaultCouponImage))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4, top: 5),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: child,
                ),
              ],
            ),
            if (tagText != null) Positioned(
                top: 14,
                right: 14,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: appSettings.appTheme.pointsIndicatorBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      tagText!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final GenRedeemPolicy policy;
  const CouponCard({Key? key, required this.policy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //AppSettings appSettings = Get.find();
    return CoolCard(
        onTap: () {
          GuestApp guestApp = Get.find();
          Get.to(() =>
              CouponDetailsScreen(policy: policy, isFavorite: guestApp.favoriteMap[policy.policyId!]!));
        },
        title: policy.title,
        imageUrl: policy.imageUrl,
        tagText: 'guestApp.pointsRequired'.trParams({'points': '${policy.pointsRequired}'}),
        child: Text(
          policy.description,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        )
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(3, 5),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin:const EdgeInsets.all(4),
            width: 125,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                        'https://images.unsplash.com/photo-1521495037281-9487183110ef?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fGNhcHB1Y2lub3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60'))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.secondaryColor.withOpacity(.7),
                  ),
                  child: const Text(
                    'Discover',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Get three cups of tea for free when you register.',
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AppTheme{
  static const primaryColor = Color(0xFF00512D);
  static const secondaryColor = Color(0xFFCF9F69);
  static const whiteColor = Color(0xFFFCFCFC);
  static const darkColor = Color(0xFF382E1E);
}

class CouponDetailsScreen extends StatelessWidget {
  final GenRedeemPolicy policy;
  final RxBool isFavorite;
  const CouponDetailsScreen({Key? key, required this.policy, required this.isFavorite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return Scaffold(
      body: Stack(children: [
        Image.network(
            policy.imageUrl ?? defaultCouponImage,
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            fit: BoxFit.cover),
        DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.8,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                    color: appSettings.appTheme.couponCardColor,
                    borderRadius: BorderRadius.circular(25)),
                child: ListView(
                  controller: controller,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30.0,
                        top: 10,
                      ),
                      child: Text(policy.title,
                          style: const TextStyle(
                              //color: AppTheme.darkColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 22)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, top: 10, bottom: 10, right: 30),
                      child: Text(
                          policy.description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              //color: AppTheme.darkColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 16)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }),
        Positioned(
            bottom: 44,
            left: 14,
            right: 14,
            child: GestureDetector(
              onTap: onRedeemNow,
              child: Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
                alignment: Alignment.center,
                height: 60,
                decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('guestApp.redeemNow'.tr,
                        style: const TextStyle(
                            color: AppTheme.whiteColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                  ],
                ),
              ),
            )
        ),
        Positioned(
            top: 50,
            right: 75,
            left: 75,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: appSettings.appTheme.pointsIndicatorBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'guestApp.pointsRequired'.trParams({'points': '${policy.pointsRequired}'}),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            )
        ),
        Positioned(
            top: 50,
            right: 15,
            child: GestureDetector(
              onTap: () {
                GuestApp guestApp = Get.find();
                guestApp.togglePolicyFavorite(policy, isFavorite);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Obx(()=>Icon(
                  isFavorite.value ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite.value ? Colors.red : Colors.black,
                )),
              ),
            )),
        Positioned(
            top: 50,
            left: 15,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                )
            ))
      ]),
    );
  }

  Future<void> onRedeemNow() async {
//    Get.to(()=>const CouponBarcodeScreen(code: 'RDM:843719847329')); // this is for test bar code function only
    GuestApp guestApp = Get.find();
    String code = await guestApp.generateCodeForPolicy(policy.policyId!);
    Get.to(()=>CouponRedeemBarcodeScreen(code: code));
  }
}

