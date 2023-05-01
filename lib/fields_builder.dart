/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_settings/card_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'card_settings_fixes.dart';
import 'ui_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';

import 'app_settings.dart';

class FieldsBuilderOptions {
  final bool detailed = true;
  final bool editing = true;
  final bool readOnly = false;
}

class FieldSectionDef {
  String label;
  FieldSectionDef({required this.label});
}

class Choice {
  String name;
  String label;
  Choice(this.name, this.label);
  @override
  String toString() {
    return label;
  }
}

class FieldDef {
  String tag;
  String label;
  double width;
  bool required;
  bool detailed;
  bool useSwitch;
  bool useDatePicker;
  bool useRadioPicker;
  int section;
  String? Function() loadValue;
  String? Function()? loadValueDetailed;
  void Function(String? value)? saveValue;
  void Function(DateTime value)? saveDateTime;
  DateTime? Function()? loadDateTime;
  List<Choice> Function()? getChoices;
  bool autofocus;
  bool allowSaveNull;
  Key? key;
  bool listOnly;
  bool isPhoneNumber;
  bool isEmail;
  bool isQueryCriteria;
  bool isInteger;
  bool isPositiveOnly;
  bool isImageUrl;
  int numberOfLines;
  bool notForCreating;
  String? tapMessage;
  int? maxLines;
  bool cannotBeZero;

  String? loadValueActual() {
    return loadValueDetailed!=null ? loadValueDetailed!() : loadValue();
  }

  FieldDef({
    required this.tag,
    required this.label,
    this.width = 100,
    this.required = false,
    required this.loadValue,
    this.loadValueDetailed,
    this.saveValue,
    this.detailed = false,
    this.useSwitch = false,
    this.section = 0,
    this.autofocus = false,
    this.allowSaveNull = false,
    this.useDatePicker = false,
    this.useRadioPicker = false,
    this.getChoices,
    this.loadDateTime,
    this.saveDateTime,
    this.key,
    this.listOnly = false,
    this.isPhoneNumber = false,
    this.isEmail = false,
    this.isQueryCriteria = false,
    this.isInteger = false,
    this.isPositiveOnly = false,
    this.isImageUrl = false,
    this.numberOfLines = 1,
    this.notForCreating = false,
    this.tapMessage,
    this.maxLines,
    this.cannotBeZero = false,
  });

  List<Choice>? choices;

  List<Choice> getChoicesCached() {
    choices ??= getChoices!();
    return choices!;
  }

  Choice getCurrentChoice() {
    var currentValue = loadValue();
    var firstWhere = getChoicesCached().firstWhere((element) => element.name == currentValue);
    return firstWhere;
  }

  List<MaskedInputFormatter>? _inputFormatters;

  List<MaskedInputFormatter> getInputFormatters() {
    _inputFormatters ??= [if(isPhoneNumber) getPhoneInputFormatter()];
    return _inputFormatters!;
  }

  String? validatorInt(int? value) {
    if (required && (value == null)) {
      return 'adminApp.fieldRequired'.trParams({'field': label});
    }
    if (isPositiveOnly && (value == null || value <= 0)) {
      return 'adminApp.fieldRequiresPositiveInteger'.trParams({'field': label});
    }
    if (cannotBeZero && (value == null || value == 0)) {
      return "adminApp.fieldCannotBeZero".trParams({'field': label});
    }
    return null;
  }

  String? validator(String? value) {
    if (required && (value == null || value.isEmpty)) {
      return 'adminApp.fieldRequired'.trParams({'field': label});
    }
    if (value != null && value.isNotEmpty) {
      var inputFormatters = getInputFormatters();
      for(var f in inputFormatters) {
        if (value.length != f.mask.length) {
          return 'adminApp.fieldFormatError'.trParams({'field': label});
        }
      }
      if (isEmail && !GetUtils.isEmail(value)) {
        return 'adminApp.fieldFormatError'.trParams({'field': label});
      }
    }
    return null;
  }
}

class FieldsBuilder {
  static const double normalWidth = 150;
  static const double shorterWidth = 120;
  static const double shorter2Width = 80;
  static const double dateWidth = 100;
  static const double dateTimeWidth = 120;
  AppSettings app;
  late List<FieldDef> fieldDefs;
  late List<FieldSectionDef> sectionDefs;
  bool isCreating = false;

  FieldsBuilder({
    required this.app,
  });

  var values = RxMap<String, String>();

  SizedBox boxOfField(String? labelText, String tag, String? value,
      double width, {queryCriteria = false}) {
    if (value!=null) {
      values[tag] = value;
    }
    return SizedBox(
      width: width,
      child: TextField(
        style: TextStyle(fontSize: Get.theme.textTheme.bodyMedium!.fontSize),
        readOnly: !queryCriteria,
        decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
            labelText: labelText,
            border: const OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        controller: TextEditingController(text: value),
        onChanged: (String value) {
          values[tag] = value;
        },
      ),
    );
  }

  List<Widget> buildFields() {
    return [for(var field in fieldDefs)
      if (!field.detailed && field.loadValueActual() != null)
        boxOfField(field.label, field.tag, field.loadValue(), field.width)];
  }

  List<Widget> buildQueryFields() {
    return [for(var field in fieldDefs)
      if (field.isQueryCriteria)
        boxOfField(field.label, field.tag, field.loadValue(), field.width, queryCriteria: true)];
  }

  void saveFieldValues({queryCriteriaOnly = false}) {
    for(var field in fieldDefs) {
      if (queryCriteriaOnly && !field.isQueryCriteria) {
        continue;
      }
      if (field.saveValue != null) {
        field.saveValue!(values[field.tag]);
      }
    }
  }

  CardSettings buildCardSettings({required VoidCallback onSubmitted}) {
    var now = DateTime.now();
    var firstDate = now.add(const Duration(days: -365*100));
    var lastDate = now.add(const Duration(days: -365*12));
    List<CardSettingsSection> sections = [];
    for(var i=0;i<sectionDefs.length;i++) {
      List<CardSettingsWidget> children = [];
      for(var field in fieldDefs.where((element) => !element.listOnly)) {
        if (field.notForCreating && isCreating) {
          continue;
        }
        if (field.section == i) {
          if (field.useSwitch) {
            children.add(CardSettingsSwitch(
              key: field.key,
              label: field.label,
              initialValue: field.loadValue() == 'yes',
              trueLabel: 'gen.yes'.tr,
              falseLabel: 'gen.no'.tr,
              onSaved: (bool? value) => values[field.tag] = value == true ? 'yes' : 'no',
            ));
          }
          else if (field.useDatePicker) {
            children.add(CardSettingsDatePicker(
              label: field.label,
              initialValue: field.loadDateTime!(),
              firstDate: firstDate,
              lastDate: lastDate,
              validator: (value) {
                if (value == null) {
                  return 'adminApp.fieldRequired'.trParams(
                      {'field': field.label});
                }
                return null;
              },
              onSaved: (value) {
                field.saveDateTime!(value!);
              },
            ));
          }
          else if (field.useRadioPicker) {
            children.add(CardSettingsRadioPicker(
              label: field.label,
              items: field.getChoicesCached(),
              initialItem: field.getCurrentChoice(),
              autovalidateMode: AutovalidateMode.always,
              onSaved: (value) {
                values[field.tag] = value!.name;
              },
            ));
          }
          else if (field.saveValue != null && field.isInteger) {
            children.add(CardSettingsInt2(
              key: field.key,
              label: field.label,
              autofocus: field.autofocus,
              initialValue: int.parse(field.loadValue()!),
              maxLength: 200,
              allowNegative: !field.isPositiveOnly,
              inputFormatters: field.getInputFormatters(),
              requiredIndicator: field.required ? const Text(
                  '*', style: TextStyle(color: Colors.red)) : null,
              onSaved: (int? value) {
                values[field.tag] = value != null ? value.toString() : '0';
              },
              onFieldSubmitted: (_) => onSubmitted(),
              validator: field.validatorInt,
            ));
          }
          else if (field.saveValue != null && !field.isInteger) {
            ValueChanged<String>? onChange;
            CardFieldLayoutBase? layoutBase;
            if (field.isImageUrl) {
              Timer? updateTimer;
              String? checkImageUrl(String? value) {
                if (value == null) return null;
                if (!value.startsWith('https://')) return null;
                return value;
              }
              var initialPut = field.loadValue();
              final previewImageUrl = Rx<String?>(checkImageUrl(initialPut));
              if (initialPut != null) {
                values[field.tag] = initialPut;
              }
              onChange = (value) {
                values[field.tag] = value;
                updateTimer?.cancel();
                updateTimer = Timer(const Duration(milliseconds: 500), () {
                  previewImageUrl.value = checkImageUrl(value);
                });
              };
              layoutBase = CardFieldLayoutBase(
                  child: Obx(() => previewImageUrl.value == null ? const Offstage() :
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: previewImageUrl.value ?? "",
                                    placeholder: (context, url) {
                                      return const CircularProgressIndicator();
                                    },
                                    errorWidget: (context, url, error) {
                                      return Tooltip(
                                        message: error.toString(),
                                        child: const Icon(
                                          size: 60,
                                          color: Colors.red,
                                          Icons.error
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),

                                    ),
                                    child: Text("adminApp.imagePreview".tr, style: const TextStyle(color: Colors.white))),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    color: Colors.blue,
                                    tooltip: "adminApp.previewImageInBrowserTooltip".tr,
                                    icon: const Icon(Icons.public),
                                    onPressed: () {
                                      launchUrl(Uri.parse(previewImageUrl.value!), mode: LaunchMode.externalApplication);
                                    },
                                  )
                                )
                              ],
                            )
                        ),
                      ),
                  )
              );
            }
            children.add(CardSettingsText(
              key: field.key,
              label: field.label,
              autofocus: field.autofocus,
              initialValue: field.loadValueActual(),
              maxLength: 200,
              inputFormatters: field.getInputFormatters(),
              requiredIndicator: field.required ? const Text(
                  '*', style: TextStyle(color: Colors.red)) : null,
              onChanged: onChange,
              numberOfLines: field.numberOfLines,
              onSaved: (String? value) {
                if (field.allowSaveNull) {
                  if (value == null || value.isEmpty) {
                    values.remove(field.tag);
                  }
                  else {
                    values[field.tag] = value;
                  }
                } else {
                  values[field.tag] = value ?? '';
                }
              },
              onFieldSubmitted: (_) => onSubmitted(),
              validator: field.validator,
            ));
            if (layoutBase != null) {
              children.add(layoutBase);
            }
          }
          else if (field.loadValueActual()!=null) {
            Widget content = SelectableText(
                field.loadValueActual() ?? '',
                style: const TextStyle(fontSize: 16),
                maxLines: field.maxLines,
                //overflow: field.maxLines == null ? null : TextOverflow.ellipsis,
            );
            if (field.tapMessage != null) {
              content = GestureDetector(
                onTap: ()=>alertDialog(field.tapMessage!),
                child: content,
              );
            }
            children.add(CardSettingsField(
              label: field.label,
              labelAlign: TextAlign.left,
              requiredIndicator: null,
              fieldPadding: null,
              content: content
            ));
          }
        }
      }
      if (children.isNotEmpty) {
        sections.add(CardSettingsSection(
            header: CardSettingsHeader(
              label: sectionDefs[i].label,
            ),
            children: children
        ));
      }
    }

    return CardSettings(
        showMaterialonIOS: true,
        labelWidth: 130,
        contentAlign: TextAlign.left,
        //margin: const EdgeInsets.all(20),
        children: sections
    );
  }
}

