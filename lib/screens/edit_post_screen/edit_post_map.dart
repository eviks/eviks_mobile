import 'dart:async';
import 'package:eviks_mobile/icons.dart';
import 'package:eviks_mobile/models/address_not_found.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import './edit_post_district.dart';
import './step_title.dart';
import '../../constants.dart';
import '../../models/address.dart';
import '../../models/failure.dart';
import '../../models/post.dart';
import '../../models/settlement.dart';
import '../../providers/localities.dart';
import '../../providers/posts.dart';
import '../../widgets/sized_config.dart';
import '../../widgets/styled_elevated_button.dart';
import '../../widgets/styled_input.dart';

class EditPostMap extends StatefulWidget {
  const EditPostMap({
    Key? key,
  }) : super(key: key);

  @override
  _EditPostMapState createState() => _EditPostMapState();
}

class _EditPostMapState extends State<EditPostMap> {
  late Post? postData;
  bool _goToNextStep = false;

  final _formKey = GlobalKey<FormState>();

  late MapController _mapController;
  late StreamSubscription _subscription;

  List<double>? _location = [49.8786270618439, 40.379108951404];
  Settlement? _city;
  Settlement? _district;
  Settlement? _subdistrict;
  String? _address;

  var _isLoading = false;
  var _typeMode = false;

  List<Address> _addresses = [];
  Timer? _searchOnStoppedTyping;

  final _controller = TextEditingController();

  @override
  void initState() {
    postData = Provider.of<Posts>(context, listen: false).postData;

    if ((postData?.lastStep ?? -1) >= 1) {
      _location = postData?.location;
      _city = postData?.city;
      _district = postData?.district;
      _subdistrict = postData?.subdistrict;
      _address = postData?.address ?? '';

      _controller.text = _address ?? '';
    }

    _city ??= getCapitalCity();

    _mapController = MapController();
    _subscription = _mapController.mapEventStream.listen((MapEvent mapEvent) {
      if (mapEvent is MapEventMoveEnd || mapEvent is MapEventDoubleTapZoomEnd) {
        _getAddressByCoords(
            [_mapController.center.longitude, _mapController.center.latitude]);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onInputChange(value) {
    const duration = Duration(milliseconds: 800);
    if (_searchOnStoppedTyping != null) {
      setState(() => _searchOnStoppedTyping!.cancel());
    }
    setState(() => _searchOnStoppedTyping =
        Timer(duration, () => _searchForAddress(value as String)));
  }

  void _exitFromTypeMode() {
    setState(() {
      _typeMode = false;
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _getAddressByCoords(List<double> coords) async {
    setState(() {
      _isLoading = true;
    });

    String _errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      setState(() {
        _location = [
          coords[0],
          coords[1],
        ];
      });

      final response = await Provider.of<Localities>(context, listen: false)
          .getAddressByCoords({
        'lng': 'az',
        'x': coords[0],
        'y': coords[1],
      });

      setState(() {
        _city = response['city'] as Settlement;
        _district = response['district'] != null
            ? response['district'] as Settlement
            : null;
        _subdistrict = response['subdistrict'] != null
            ? response['subdistrict'] as Settlement
            : null;
        _address = response['address'] as String;
        _controller.value = TextEditingValue(text: _address ?? '');
      });
    } on AddressNotFound {
      // no user notification
    } on Failure catch (error) {
      if (error.statusCode >= 500) {
        _errorMessage = AppLocalizations.of(context)!.serverError;
      } else {
        _errorMessage = error.toString();
      }
    } catch (error) {
      _errorMessage = AppLocalizations.of(context)!.unknownError;
    }

    if (_errorMessage.isNotEmpty) {
      displayErrorMessage(context, _errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _searchForAddress(String value) async {
    setState(() {
      _isLoading = true;
    });

    String _errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      final response =
          await Provider.of<Localities>(context, listen: false).geocoder(value);

      setState(() {
        _addresses = response;
      });
    } on Failure catch (error) {
      if (error.statusCode >= 500) {
        _errorMessage = AppLocalizations.of(context)!.serverError;
      } else {
        _errorMessage = error.toString();
      }
    } catch (error) {
      _errorMessage = AppLocalizations.of(context)!.unknownError;
    }

    if (_errorMessage.isNotEmpty) {
      displayErrorMessage(context, _errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void onAddressSelect(List<double> coords) {
    _exitFromTypeMode();

    _mapController.move(LatLng(coords[1], coords[0]), 18);

    _getAddressByCoords(coords);
  }

  void _continuePressed() {
    if (_city == null) {
      displayErrorMessage(context, AppLocalizations.of(context)!.cityError);
      return;
    }

    if (_district == null) {
      displayErrorMessage(context, AppLocalizations.of(context)!.districtError);
      return;
    }

    if ((_district?.children?.isNotEmpty ?? false) && _subdistrict == null) {
      displayErrorMessage(
          context, AppLocalizations.of(context)!.subdistrictError);
      return;
    }

    print(
      _location?[0],
    );
    print(
      _location?[1],
    );

    if (_formKey.currentState == null) {
      return;
    }

    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _goToNextStep = true;
    _updatePost();
  }

  void _updatePost() {
    Provider.of<Posts>(context, listen: false).updatePost(
      postData?.copyWith(
        city: _city,
        district: _district,
        subdistrict: _subdistrict,
        address: _address,
        location: _location,
        lastStep: 1,
        step: _goToNextStep ? 2 : 0,
      ),
    );
  }

  void _prevStep(Post? postData) {
    _updatePost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StepTitle(
          title: AppLocalizations.of(context)!.address,
          icon: CustomIcons.marker,
        ),
        leading: IconButton(
          onPressed: () {
            _prevStep(postData);
          },
          icon: const Icon(CustomIcons.back),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(_location?[1] ?? 0, _location?[0] ?? 0),
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    'http://maps.gomap.az/info/xyz.do?lng=az&x={x}&y={y}&z={z}&f=jpg',
              ),
            ],
          ),
          Center(
            child: SvgPicture.asset(
              "assets/img/svg/location.svg",
              width: 60.0,
              height: 60.0,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: _typeMode
                        ? null
                        : const BorderRadius.only(
                            bottomRight: Radius.circular(
                              50.0,
                            ),
                            bottomLeft: Radius.circular(
                              50.0,
                            )),
                  ),
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 8.0),
                      child: Column(
                        children: [
                          if (!_typeMode)
                            EditPostDistrict(
                              city: _city ?? getCapitalCity(),
                              district: _district,
                              subdistrict: _subdistrict,
                              updateCity: (Settlement value) {
                                setState(
                                  () {
                                    _city = value;
                                    _district = null;
                                    _subdistrict = null;
                                    if (_city?.x != null && _city?.y != null) {
                                      _location = [_city!.x!, _city!.y!];
                                      _mapController.move(
                                          LatLng(_city!.y!, _city!.x!), 12);
                                    }
                                  },
                                );
                              },
                              updateDistrict: (Settlement districtValue,
                                  Settlement? subdistrictValue) {
                                setState(() {
                                  _district = districtValue;
                                  _subdistrict = subdistrictValue;
                                });
                              },
                            ),
                          StyledInput(
                            icon: CustomIcons.marker,
                            onFocus: (value) {
                              setState(() {
                                _typeMode = value;
                              });
                            },
                            onChanged: _onInputChange,
                            keyboardType: TextInputType.text,
                            controller: _controller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .errorAddress;
                              } else if ((_location?[0] ?? 0) == 0 ||
                                  (_location?[1] ?? 0) == 0 ||
                                  _city == null ||
                                  _district == null) {
                                return AppLocalizations.of(context)!
                                    .wrongAddress;
                              }
                            },
                            onSaved: (value) {
                              _address = value ?? '';
                            },
                            suffix: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  _controller.text = '';
                                },
                                child: Icon(
                                  CustomIcons.close,
                                  size: 14.0,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            prefix: _typeMode
                                ? IconButton(
                                    onPressed: _exitFromTypeMode,
                                    icon: Icon(
                                      CustomIcons.back,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              if (_typeMode)
                Expanded(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    width: SizeConfig.screenWidth,
                    child: _isLoading
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemBuilder: (ctx, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(_addresses[index].name),
                                  subtitle: Text(_addresses[index].address),
                                  onTap: () {
                                    onAddressSelect([
                                      _addresses[index].longitude,
                                      _addresses[index].latitude
                                    ]);
                                  },
                                ),
                              );
                            },
                            itemCount: _addresses.length,
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _typeMode
          ? null
          : StyledElevatedButton(
              secondary: true,
              text: AppLocalizations.of(context)!.next,
              loading: _isLoading,
              onPressed: _continuePressed,
              width: SizeConfig.safeBlockHorizontal * 100.0,
              suffixIcon: CustomIcons.next,
            ),
    );
  }
}
