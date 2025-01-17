import 'package:eviks_mobile/models/post.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './metro_station.dart';
import './settlement.dart';

enum SortType {
  priceAsc,
  priceDsc,
  sqmAsc,
  sqmDsc,
  dateAsc,
  dateDsc,
}

String sortDescription(SortType userType, BuildContext ctx) {
  switch (userType) {
    case SortType.priceAsc:
      return AppLocalizations.of(ctx)!.priceAsc;
    case SortType.priceDsc:
      return AppLocalizations.of(ctx)!.priceDsc;
    case SortType.sqmAsc:
      return AppLocalizations.of(ctx)!.sqmAsc;
    case SortType.sqmDsc:
      return AppLocalizations.of(ctx)!.sqmDsc;
    case SortType.dateAsc:
      return AppLocalizations.of(ctx)!.dateAsc;
    case SortType.dateDsc:
      return AppLocalizations.of(ctx)!.dateDsc;
    default:
      return '';
  }
}

class Filters {
  Settlement city;
  List<Settlement>? districts;
  List<Settlement>? subdistricts;
  List<MetroStation>? metroStations;
  DealType dealType;
  EstateType estateType;
  ApartmentType? apartmentType;
  int? priceMin;
  int? priceMax;
  int? roomsMin;
  int? roomsMax;
  int? sqmMin;
  int? sqmMax;
  int? livingRoomsSqmMin;
  int? livingRoomsSqmMax;
  int? kitchenSqmMin;
  int? kitchenSqmMax;
  int? lotSqmMin;
  int? lotSqmMax;
  int? floorMin;
  int? floorMax;
  int? totalFloorsMin;
  int? totalFloorsMax;
  List<List<double>>? searchArea;
  bool tempSearchArea;
  bool? hasVideo;
  bool? documented;
  bool? fromOwner;
  bool? withoutRedevelopment;
  SortType sort;

  Filters({
    required this.city,
    required this.dealType,
    this.districts,
    this.subdistricts,
    this.metroStations,
    required this.estateType,
    this.apartmentType,
    this.priceMin,
    this.priceMax,
    this.roomsMin,
    this.roomsMax,
    this.sqmMin,
    this.sqmMax,
    this.livingRoomsSqmMin,
    this.livingRoomsSqmMax,
    this.kitchenSqmMin,
    this.kitchenSqmMax,
    this.lotSqmMin,
    this.lotSqmMax,
    this.floorMin,
    this.floorMax,
    this.totalFloorsMin,
    this.totalFloorsMax,
    this.searchArea,
    this.tempSearchArea = false,
    this.hasVideo,
    this.documented,
    this.fromOwner,
    this.withoutRedevelopment,
    this.sort = SortType.dateDsc,
  });

  Map<String, dynamic> toQueryParameters() => {
        'cityId': city.id,
        'dealType': dealType.toString().replaceAll('DealType.', ''),
        'districtId': districts?.map((e) => e.id).toList().join(','),
        'subdistrictId': subdistricts?.map((e) => e.id).toList().join(','),
        'metroStationId': metroStations?.map((e) => e.id).toList().join(','),
        'estateType': estateType.toString().replaceAll('EstateType.', ''),
        'apartmentType':
            apartmentType?.toString().replaceAll('ApartmentType.', ''),
        'priceMin': priceMin == 0 ? null : priceMin?.toString(),
        'priceMax': priceMax == 0 ? null : priceMax?.toString(),
        'roomsMin': roomsMin == 0 ? null : roomsMin?.toString(),
        'roomsMax': roomsMax == 0 ? null : roomsMax?.toString(),
        'sqmMin': sqmMin == 0 ? null : sqmMin?.toString(),
        'sqmMax': sqmMax == 0 ? null : sqmMax?.toString(),
        'livingRoomsSqmMin':
            livingRoomsSqmMin == 0 ? null : livingRoomsSqmMin?.toString(),
        'livingRoomsSqmMax':
            livingRoomsSqmMax == 0 ? null : livingRoomsSqmMax?.toString(),
        'kitchenSqmMin': kitchenSqmMin == 0 ? null : kitchenSqmMin?.toString(),
        'kitchenSqmMax': kitchenSqmMax == 0 ? null : kitchenSqmMax?.toString(),
        'lotSqmMin': lotSqmMin == 0 ? null : lotSqmMin?.toString(),
        'lotSqmMax': lotSqmMax == 0 ? null : lotSqmMax?.toString(),
        'floorMin': floorMin == 0 ? null : floorMin?.toString(),
        'floorMax': floorMax == 0 ? null : floorMax?.toString(),
        'totalFloorsMin':
            totalFloorsMin == 0 ? null : totalFloorsMin?.toString(),
        'totalFloorsMax':
            totalFloorsMax == 0 ? null : totalFloorsMax?.toString(),
        'searchArea':
            searchArea?.isEmpty ?? true ? null : searchArea?.join(','),
        'hasVideo': hasVideo == true ? 'true' : null,
        'documented': documented == true ? 'true' : null,
        'fromOwner': fromOwner == true ? 'true' : null,
        'withoutRedevelopment': withoutRedevelopment == true ? 'true' : null,
        'sort': sort.toString().replaceAll('SortType.', ''),
      };

  Filters copy() {
    return Filters(
      city: city,
      dealType: dealType,
      districts: districts,
      subdistricts: subdistricts,
      metroStations: metroStations,
      estateType: estateType,
      apartmentType: apartmentType,
      priceMin: priceMin,
      priceMax: priceMax,
      roomsMin: roomsMin,
      roomsMax: roomsMax,
      sqmMin: sqmMin,
      sqmMax: sqmMax,
      livingRoomsSqmMin: livingRoomsSqmMin,
      livingRoomsSqmMax: livingRoomsSqmMax,
      kitchenSqmMin: kitchenSqmMin,
      kitchenSqmMax: kitchenSqmMax,
      lotSqmMin: lotSqmMin,
      lotSqmMax: lotSqmMax,
      floorMin: floorMin,
      floorMax: floorMax,
      totalFloorsMin: totalFloorsMin,
      totalFloorsMax: totalFloorsMax,
      searchArea: searchArea,
      tempSearchArea: tempSearchArea,
      hasVideo: hasVideo,
      documented: documented,
      fromOwner: fromOwner,
      withoutRedevelopment: withoutRedevelopment,
      sort: sort,
    );
  }
}
