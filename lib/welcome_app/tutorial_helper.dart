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

import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'widget_finder.dart';

class TutorialHelper {
  WidgetFinder finder;
  WidgetFinder contextFinder;
  TapDownDetails? tapDownDetails;
  late TutorialCoachMark tutorialCoachMark;
  String? title;
  String description;
  bool tapWidgetAfterFinish;
  Duration? waitForWidget;
  ShapeLightFocus? shape;
  TutorialHelper({
    required this.finder,
    required this.contextFinder,
    this.title,
    required this.description,
    this.tapWidgetAfterFinish = false,
    this.waitForWidget,
    this.shape,
  });

  final Completer _completer = Completer();

  Future<void> show() async {
    if (waitForWidget != null) {
      await Future.delayed(waitForWidget!);
      await waitWidgetToAppear(WidgetFinder(matcher: TypeMatcher(type: CardSettings)));
    }
    BuildContext context = contextFinder.evaluate().single;
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        targetPosition: getWidgetPosition(finder),
        alignSkip: Alignment.bottomRight,
        shape: shape,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(top: 100, left: 20, right: 20),
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.red[700]!.withOpacity(0.6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (title!=null)
                    ...[
                      Text(
                        title!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25.0),
                      ),
                      const SizedBox(height: 10),
                    ],
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.red,
      skipWidget: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
              "quickTour.skipBtn".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              )
          ),
        ),
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      onFinish: () async {
        tutorialCoachMark.skip();
        await Future.delayed(const Duration(milliseconds: 0));
        if (tapWidgetAfterFinish) {
          var gestureSimulator = GestureSimulator.create();
          await gestureSimulator.tap(finder);
        }
        _completer.complete();
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        log("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
        tapDownDetails = tapDetails;
      },
    );
    if (context.mounted) {
      tutorialCoachMark.show(context: context);
    }
    else {
      log('error: context.mounted is false');
    }
    return _completer.future;
  }
}

