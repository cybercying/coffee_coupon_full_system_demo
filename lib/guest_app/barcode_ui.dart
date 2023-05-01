/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:protocol/client_state.dart';

import '../admin_app/admin_app.dart';
import '../app_settings.dart';
import '../ui_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zxing2/qrcode.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

Future<ui.Image> decodeRawRgba(Uint8List bytes, int width, int height) {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete
  );
  return completer.future;
}

class BarcodeResult {
  ui.Image uiImage;
  img.Image imgImage;
  BarcodeResult({required  this.uiImage, required this.imgImage});

  static Future<BarcodeResult> generateBarcode(String input) async {
    var qrcode = Encoder.encode(input, ErrorCorrectionLevel.h);
    var matrix = qrcode.matrix!;
    var scale = 4;

    var image = img.Image(
        width: matrix.width * scale,
        height: matrix.height * scale,
        numChannels: 4);
    for (var x = 0; x < matrix.width; x++) {
      for (var y = 0; y < matrix.height; y++) {
        if (matrix.get(x, y) == 1) {
          img.fillRect(image,
              x1: x * scale,
              y1: y * scale,
              x2: x * scale + scale,
              y2: y * scale + scale,
              color: img.ColorRgba8(0, 0, 0, 0xFF));
        }
      }
    }
    return BarcodeResult(
      uiImage: await decodeRawRgba(image.toUint8List(), image.width, image.height),
      imgImage: image,
    );
  }
}

Future<String> saveScreenshotToFile(GlobalKey scr) async {
  AppSettings appSettings = Get.find();
  RenderRepaintBoundary boundary = scr.currentContext!.findRenderObject() as RenderRepaintBoundary;
  var image = await boundary.toImage();
  var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  var dir = Directory('${appSettings.appConfig.dir ?? '.'}/snapshot');
  if (!await dir.exists()) {
    await dir.create();
  }
  DateTime now = DateTime.now();
  DateFormat df = DateFormat('yyyy-MM-dd-HHmmss');
  var file = File('${dir.path}/barcode-${df.format(now)}.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  log('saveScreenshotToFile(): size: ${byteData.lengthInBytes}, file: ${file.path}');
  return file.path;
}

class CouponBarcodeScreen extends StatefulWidget {
  final String code;
  const CouponBarcodeScreen({super.key, required this.code});

  @override
  State<CouponBarcodeScreen> createState() => _CouponBarcodeScreenState();
}

class _CouponBarcodeScreenState extends State<CouponBarcodeScreen> {
  // Test code: RDM:84371984732914
  ui.Image? image;
  BarcodeResult? barcodeResult;
  final GlobalKey scr = GlobalKey();
  final input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: scr,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('2D barcode'),
          ),
          body: Stack(
              children: [
                Positioned(
                    left: 20,
                    top: 20,
                    right: 20,
                    bottom: 20,
                    child: RawImage(
                        image: image,
                        scale: 0.3,
                    )
                ),
                Positioned(
                    top: 40,
                    left:40,
                    right: 40,
                    child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Enter string",
                          border: OutlineInputBorder(),
                        ),
                        controller: input,
                        onChanged: (value) async {
                          await generate();
                        },
                    )
                ),
                Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        onDecode();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Decode'),
                      )

                    )
                )
              ]
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    input.text = widget.code;
    Future.delayed(Duration.zero, () async {
      await generate();
    });
  }

  Future<void> generate() async {
    barcodeResult = await BarcodeResult.generateBarcode(input.text);
    setState(() {
      image = barcodeResult!.uiImage;
    });
  }

  void onDecode() async {
    try {
      var path = await saveScreenshotToFile(scr);
      var image = img.decodePng(await File(path).readAsBytes())!;

      LuminanceSource source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4)
              .getBytes(order: img.ChannelOrder.abgr)
              .buffer
              .asInt32List());
      var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

      var reader = QRCodeReader();
      var result = reader.decode(bitmap);
      alertDialog(result.toString());
    }
    on Exception catch(e, s) {
      alertErrorDialog(e.toString());
      log(s.toString());
    }
  }
}

class CouponRedeemBarcodeScreen extends StatefulWidget {
  final String code;
  const CouponRedeemBarcodeScreen({super.key, required this.code});

  @override
  State<CouponRedeemBarcodeScreen> createState() => _CouponRedeemBarcodeScreenState();
}

class _CouponRedeemBarcodeScreenState extends State<CouponRedeemBarcodeScreen> {
  ui.Image? image;
  BarcodeResult? barcodeResult;
  final GlobalKey scr = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return RepaintBoundary(
      key: scr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("redeem.appBar".tr),
          ),
          body: Stack(
              children: [
                Positioned(
                    left: 20,
                    top: 20,
                    right: 20,
                    bottom: 20,
                    child: RawImage(
                      image: image,
                      scale: 0.3,
                    )
                ),
                Positioned(
                    bottom: 40,
                    left: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          uiSimpleDialog("redeem.selectMockDeviceToSimulate".tr, <OptionAndPressed>[
                            for(int index=0;index<appSettings.mockListeners.length;index++)
                              OptionAndPressed('${appSettings.mockListeners[index].receiver.description}(${appSettings.mockListeners[index].receiver.phone})', () async {
                                await useMockDeviceToScan(index, appSettings.mockListeners[index].receiver);
                              })
                          ]);
                          //onDecode();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("redeem.barcodeDemoHintBtn".tr),
                        )

                    )
                )
              ]
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await generate();
    });
  }

  Future<void> generate() async {
    barcodeResult = await BarcodeResult.generateBarcode(widget.code);
    setState(() {
      image = barcodeResult!.uiImage;
    });
  }

  Future<void> useMockDeviceToScan(int index, MockDevice receiver) async {
    var path = await saveScreenshotToFile(scr);
    Get.back();
    Get.back();
    AppSettings appSettings = Get.find();
    await appSettings.changeCurrentMockDeviceByIndex(index);
    AdminApp adminApp = Get.find();
    if (appSettings.mode.value == AppMode.adminApp && adminApp.isCurrentlyLoggedIn) {
      await adminApp.scanBarcodeImageForRedeem(path);
    }
    else {
      alertErrorDialog("redeem.selectedDeviceMustBeUsingAdminAndLoggedIn".tr);
    }
  }
}

Future<String> decodeBarcodeImage(String path) async {
  try {
    var image = img.decodePng(await File(path).readAsBytes())!;
    LuminanceSource source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List());
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
    var reader = QRCodeReader();
    return reader.decode(bitmap).toString();
  }
  on Exception catch(e, s) {
    alertErrorDialog(e.toString());
    log(s.toString());
    rethrow;
  }
}

