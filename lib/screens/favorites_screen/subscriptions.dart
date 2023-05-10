import 'package:collection/collection.dart';
import 'package:eviks_mobile/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/failure.dart';
import '../../models/metro_station.dart';
import '../../models/settlement.dart';
import '../../providers/localities.dart';
import '../../providers/posts.dart';
import '../../providers/subscriptions.dart' as provider;
import '../../widgets/sized_config.dart';
import '../../widgets/subscription_modal.dart';
import '../tabs_screen.dart';

enum MenuItems { edit, delete }

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  var _isInit = true;

  Future<void> _fetchSubscriptions() async {
    String errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    try {
      await Provider.of<provider.Subscriptions>(context, listen: false)
          .getSubscriptions();
    } on Failure catch (error) {
      if (error.statusCode >= 500) {
        errorMessage = AppLocalizations.of(context)!.serverError;
      } else {
        errorMessage = AppLocalizations.of(context)!.networkError;
      }
    } catch (error) {
      errorMessage = AppLocalizations.of(context)!.unknownError;
    }

    if (errorMessage.isNotEmpty) {
      if (!mounted) return;
      showSnackBar(context, errorMessage);
    }
  }

  Future<void> _goToPosts(String url) async {
    final params = Uri.splitQueryString(url);

    Settlement city;
    List<Settlement>? districts;
    List<Settlement>? subdistricts;
    List<MetroStation>? metroStations;

    // City
    final result = await Provider.of<Localities>(context, listen: false)
        .getLocalities({'id': params["cityId"]!, 'type': '2'});
    city = result[0];

    // District
    if (params["districtId"] != null) {
      if (!mounted) return;
      districts = await Provider.of<Localities>(context, listen: false)
          .getLocalities({'id': params["districtId"]!});
    }

    // Subdistrict
    if (params["subdistrictId"] != null) {
      if (!mounted) return;
      subdistricts = await Provider.of<Localities>(context, listen: false)
          .getLocalities({'id': params["subdistrictId"]!});
    }

    // Metro station
    if (params["metroStationId"] != null) {
      final metroStationId = (params["metroStationId"]!).split(',');
      metroStations = city.metroStations
          ?.where(
            (element) =>
                metroStationId
                    .firstWhereOrNull((id) => id == element.id.toString()) !=
                null,
          )
          .toList();
    }

    if (!mounted) return;
    final filters = Provider.of<Posts>(context, listen: false)
        .getFiltersfromQueryParameters(
      params,
      city,
      districts,
      subdistricts,
      metroStations,
    );

    Provider.of<Posts>(context, listen: false).setFilters(filters);

    Navigator.of(context).pushNamedAndRemoveUntil(
      TabsScreen.routeName,
      (route) => false,
      arguments: Pages.posts,
    );
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_isInit) {
      Provider.of<provider.Subscriptions>(context, listen: false)
          .clearSubscriptions();

      await _fetchSubscriptions();

      if (mounted) {
        setState(() {
          _isInit = false;
        });
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (_isInit) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      final subscriptions =
          Provider.of<provider.Subscriptions>(context).subscriptions;
      return subscriptions.isEmpty
          ? SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 40.0,
                          child: Image.asset(
                            "assets/img/illustrations/subscriptions.png",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .subscriptionsTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                AppLocalizations.of(context)!.subscriptionsHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            child: ListTile(
                              key: Key(subscriptions[index].id),
                              leading: const Icon(CustomIcons.search),
                              title: Text(subscriptions[index].name),
                              trailing: PopupMenuButton<MenuItems>(
                                onSelected: (value) async {
                                  if (value == MenuItems.delete) {
                                    await Provider.of<provider.Subscriptions>(
                                      context,
                                      listen: false,
                                    ).deleteSubscription(
                                      subscriptions[index].id,
                                    );
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        return SubscriptionModal(
                                          subscriptions[index].url,
                                          subscriptions[index].name,
                                          subscriptions[index].id,
                                        );
                                      },
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext bc) {
                                  return [
                                    PopupMenuItem(
                                      value: MenuItems.edit,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .subscriptionEdit,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: MenuItems.delete,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .subscriptionDelete,
                                      ),
                                    ),
                                  ];
                                },
                              ),
                              onTap: () {
                                _goToPosts(subscriptions[index].url);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: subscriptions.length,
                ),
              ],
            );
    }
  }
}