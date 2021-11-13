import 'package:eviks_mobile/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';
import '../../providers/posts.dart';
import '../../widgets/sized_config.dart';
import '../../widgets/styled_elevated_button.dart';
import '../../widgets/styled_input.dart';
import '../../widgets/toggle_field.dart';
import './step_title.dart';

class EditPostEstateInfo extends StatefulWidget {
  const EditPostEstateInfo({
    Key? key,
  }) : super(key: key);

  @override
  _EditPostEstateInfoState createState() => _EditPostEstateInfoState();
}

class _EditPostEstateInfoState extends State<EditPostEstateInfo> {
  late Post? postData;

  final _formKey = GlobalKey<FormState>();

  int? _rooms;
  int? _sqm;
  int? _livingRoomsSqm;
  int? _kitchenSqm;
  int? _lotSqm;
  int? _floor;
  int? _totalFloors;
  Renovation? _renovation;
  bool? _redevelopment = false;
  bool? _documented = false;

  final _totalFloorsController = TextEditingController();

  late bool _isHouse;

  @override
  void initState() {
    postData = Provider.of<Posts>(context, listen: false).postData;

    if ((postData?.lastStep ?? -1) >= 2) {
      _rooms = postData?.rooms;
      _sqm = postData?.sqm;
      _livingRoomsSqm = postData?.livingRoomsSqm;
      _kitchenSqm = postData?.kitchenSqm;
      _lotSqm = postData?.lotSqm;
      _floor = postData?.floor;
      _totalFloors = postData?.totalFloors;
      _renovation = postData?.renovation;
      _redevelopment = postData?.redevelopment;
      _documented = postData?.documented;
    }

    _totalFloorsController.text = _totalFloors?.toString() ?? '';

    _isHouse = postData?.estateType == EstateType.house;
    super.initState();
  }

  void _updatePost(int lastStep, int step) {
    Provider.of<Posts>(context, listen: false).updatePost(postData?.copyWith(
      rooms: _rooms,
      sqm: _sqm,
      livingRoomsSqm: _livingRoomsSqm,
      kitchenSqm: _kitchenSqm,
      lotSqm: _lotSqm,
      floor: _floor,
      totalFloors: _totalFloors,
      renovation: _renovation,
      redevelopment: _redevelopment,
      documented: _documented,
      lastStep: lastStep,
      step: step,
    ));
  }

  void _continuePressed() {
    if (_formKey.currentState == null) {
      return;
    }

    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _updatePost(2, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal * 15.0,
                8.0, SizeConfig.safeBlockHorizontal * 15.0, 32.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepTitle(
                      title: AppLocalizations.of(context)!.estateInfo,
                      icon: CustomIcons.house,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 40.0,
                      child: StyledInput(
                        icon: CustomIcons.door,
                        title: AppLocalizations.of(context)!.rooms,
                        initialValue: _rooms?.toString(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .errorRequiredField;
                          }
                        },
                        onSaved: (value) {
                          _rooms =
                              value?.isEmpty ?? true ? 0 : int.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 40.0,
                      child: StyledInput(
                        icon: CustomIcons.sqm,
                        title: AppLocalizations.of(context)!.sqm,
                        initialValue: _sqm?.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .errorRequiredField;
                          }
                        },
                        onSaved: (value) {
                          _sqm = value?.isEmpty ?? true ? 0 : int.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 40.0,
                      child: StyledInput(
                        icon: CustomIcons.sqm,
                        title: AppLocalizations.of(context)!.livingRoomsSqm,
                        initialValue: _livingRoomsSqm?.toString(),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _livingRoomsSqm =
                              value?.isEmpty ?? true ? 0 : int.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 40.0,
                      child: StyledInput(
                        icon: CustomIcons.sqm,
                        title: AppLocalizations.of(context)!.kitchenSqm,
                        initialValue: _kitchenSqm?.toString(),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _kitchenSqm =
                              value?.isEmpty ?? true ? 0 : int.parse(value!);
                        },
                      ),
                    ),
                    Visibility(
                      visible: _isHouse,
                      child: SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 40.0,
                        child: StyledInput(
                          icon: CustomIcons.garden,
                          title: AppLocalizations.of(context)!.lotSqm,
                          initialValue: _lotSqm?.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_isHouse && (value == null || value.isEmpty)) {
                              return AppLocalizations.of(context)!
                                  .errorRequiredField;
                            }
                          },
                          onSaved: (value) {
                            _lotSqm =
                                value?.isEmpty ?? true ? 0 : int.parse(value!);
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !_isHouse,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 25.0,
                            child: StyledInput(
                              icon: CustomIcons.elevator,
                              title: AppLocalizations.of(context)!.floor,
                              initialValue: _floor?.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (_isHouse) {
                                  return null;
                                } else if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .errorRequiredField;
                                } else if (_totalFloorsController
                                        .value.text.isNotEmpty &&
                                    int.parse(
                                            _totalFloorsController.value.text) <
                                        int.parse(value)) {
                                  return AppLocalizations.of(context)!
                                      .errorFloor;
                                }
                              },
                              onSaved: (value) {
                                _floor = value?.isEmpty ?? true
                                    ? 0
                                    : int.parse(value!);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 40.0,
                            ),
                            child: Text(' - '),
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 25.0,
                            child: StyledInput(
                              title: '',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: _totalFloorsController,
                              validator: (value) {
                                if (!_isHouse &&
                                    (value == null || value.isEmpty)) {
                                  return AppLocalizations.of(context)!
                                      .errorRequiredField;
                                }
                              },
                              onSaved: (value) {
                                _totalFloors = value?.isEmpty ?? true
                                    ? 0
                                    : int.parse(value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _isHouse,
                      child: SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 40.0,
                        child: StyledInput(
                          icon: CustomIcons.elevator,
                          title: AppLocalizations.of(context)!.totalFloors,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _totalFloorsController,
                          onSaved: (value) {
                            _totalFloors =
                                value?.isEmpty ?? true ? 0 : int.parse(value!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    SwitchListTile(
                        value: _documented ?? false,
                        secondary: const Icon(CustomIcons.document),
                        title: Text(AppLocalizations.of(context)!.documented),
                        onChanged: (bool? value) {
                          setState(() {
                            _documented = value;
                          });
                        }),
                    SwitchListTile(
                        value: _redevelopment ?? false,
                        secondary: const Icon(CustomIcons.hammer),
                        title:
                            Text(AppLocalizations.of(context)!.redevelopment),
                        onChanged: (bool? value) {
                          setState(() {
                            _redevelopment = value;
                          });
                        }),
                    ToggleFormField<Renovation>(
                      title: AppLocalizations.of(context)!.renovation,
                      values: Renovation.values,
                      initialValue: _renovation,
                      getDescription: renovationDescription,
                      direction: Axis.vertical,
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.fieldIsRequired;
                        }
                      },
                      onSaved: (value) {
                        _renovation = value;
                      },
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(10.0, 10.0),
                )
              ],
            ),
            child: StyledElevatedButton(
              secondary: true,
              text: AppLocalizations.of(context)!.next,
              onPressed: _continuePressed,
              width: SizeConfig.safeBlockHorizontal * 100.0,
              suffixIcon: CustomIcons.next,
            ),
          ),
        ),
      ],
    );
  }
}
