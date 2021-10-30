import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './settlement.dart';

enum UserType {
  owner,
  agent,
}

enum EstateType {
  apartment,
  house,
}
enum ApartmentType {
  newBuilding,
  secondaryBuilding,
}

enum DealType {
  sale,
  rent,
  rentPerDay,
}

enum Renovation {
  cosmetic,
  designer,
  noRenovation,
}

String userTypeDescription(UserType userType, BuildContext ctx) {
  switch (userType) {
    case UserType.owner:
      return AppLocalizations.of(ctx)!.owner;
    case UserType.agent:
      return AppLocalizations.of(ctx)!.agent;
    default:
      return '';
  }
}

String estateTypeDescription(EstateType estateType, BuildContext ctx) {
  switch (estateType) {
    case EstateType.apartment:
      return AppLocalizations.of(ctx)!.apartment;
    case EstateType.house:
      return AppLocalizations.of(ctx)!.house;
    default:
      return '';
  }
}

String apartmentTypeDescription(ApartmentType apartmentType, BuildContext ctx) {
  switch (apartmentType) {
    case ApartmentType.newBuilding:
      return AppLocalizations.of(ctx)!.newBuilding;
    case ApartmentType.secondaryBuilding:
      return AppLocalizations.of(ctx)!.resale;
    default:
      return '';
  }
}

String dealTypeDescription(DealType dealType, BuildContext ctx) {
  switch (dealType) {
    case DealType.sale:
      return AppLocalizations.of(ctx)!.sale;
    case DealType.rent:
      return AppLocalizations.of(ctx)!.rent;
    case DealType.rentPerDay:
      return AppLocalizations.of(ctx)!.rentPerDay;
    default:
      return '';
  }
}

String renovationDescription(Renovation renovation, BuildContext ctx) {
  switch (renovation) {
    case Renovation.cosmetic:
      return AppLocalizations.of(ctx)!.cosmetic;
    case Renovation.designer:
      return AppLocalizations.of(ctx)!.designer;
    case Renovation.noRenovation:
      return AppLocalizations.of(ctx)!.noRenovation;
    default:
      return '';
  }
}

class Post {
  final int id;
  final UserType userType;
  final EstateType estateType;
  final ApartmentType? apartmentType;
  final DealType dealType;
  final List<double> location;
  final Settlement? city;
  final Settlement? district;
  final Settlement? subdistrict;
  final String address;
  final int rooms;
  final int sqm;
  final int? livingRoomsSqm;
  final int? kitchenSqm;
  final int? lotSqm;
  final int? floor;
  final int? totalFloors;
  final bool? redevelopment;
  final bool? documented;
  final Renovation renovation;
  final int? yearBuild;
  final double? ceilingHeight;
  final bool? elevator;
  final bool? parkingLot;
  final String description;
  final bool? balcony;
  final bool? furniture;
  final bool? kitchenFurniture;
  final bool? cableTv;
  final bool? phone;
  final bool? internet;
  final bool? electricity;
  final bool? gas;
  final bool? water;
  final bool? heating;
  final bool? tv;
  final bool? conditioner;
  final bool? washingMachine;
  final bool? dishwasher;
  final bool? refrigerator;
  final bool? kidsAllowed;
  final bool? petsAllowed;
  final bool? garage;
  final bool? pool;
  final bool? bathhouse;
  final int price;
  final List<String> images;
  final int step;

  Post({
    required this.id,
    required this.userType,
    required this.estateType,
    this.apartmentType,
    required this.dealType,
    required this.location,
    required this.city,
    required this.district,
    this.subdistrict,
    required this.address,
    required this.rooms,
    required this.sqm,
    this.livingRoomsSqm,
    this.kitchenSqm,
    this.lotSqm,
    this.floor,
    this.totalFloors,
    this.redevelopment = false,
    this.documented = false,
    required this.renovation,
    this.yearBuild,
    this.ceilingHeight,
    this.elevator = false,
    this.parkingLot = false,
    required this.description,
    this.balcony = false,
    this.furniture = false,
    this.kitchenFurniture = false,
    this.cableTv = false,
    this.phone = false,
    this.internet = false,
    this.electricity = false,
    this.gas = false,
    this.water = false,
    this.heating = false,
    this.tv = false,
    this.conditioner = false,
    this.washingMachine = false,
    this.dishwasher = false,
    this.refrigerator = false,
    this.kidsAllowed = false,
    this.petsAllowed = false,
    this.garage = false,
    this.pool = false,
    this.bathhouse = false,
    required this.price,
    required this.images,
    this.step = 0,
  });

  factory Post.fromJson(dynamic json) {
    return Post(
      id: json['_id'] as int,
      userType: UserType.values.firstWhere((element) =>
          element.toString() == 'UserType.${json['userType'] as String}'),
      estateType: EstateType.values.firstWhere((element) =>
          element.toString() == 'EstateType.${json['estateType'] as String}'),
      apartmentType: json['apartmentType'] == null
          ? null
          : ApartmentType.values.firstWhere((element) =>
              element.toString() ==
              'ApartmentType.${json['apartmentType'] as String}'),
      dealType: DealType.values.firstWhere((element) =>
          element.toString() == 'DealType.${json['dealType'] as String}'),
      location: (json['location'] as List<dynamic>).cast<double>(),
      city: Settlement.fromJson(json['city']),
      district: Settlement.fromJson(
        json['district'],
      ),
      subdistrict: json['subdistrict'] == null
          ? null
          : Settlement.fromJson(
              json['subdistrict'],
            ),
      address: json['address'] as String,
      rooms: json['rooms'] as int,
      sqm: json['sqm'] as int,
      livingRoomsSqm:
          json['livingRoomsSqm'] == null ? null : json['livingRoomsSqm'] as int,
      kitchenSqm: json['kitchenSqm'] == null ? null : json['kitchenSqm'] as int,
      lotSqm: json['lotSqm'] == null ? null : json['lotSqm'] as int,
      floor: json['floor'] as int,
      totalFloors: json['totalFloors'] as int,
      redevelopment:
          json['redevelopment'] == null ? null : json['redevelopment'] as bool,
      documented:
          json['documented'] == null ? null : json['documented'] as bool,
      renovation: Renovation.values.firstWhere((element) =>
          element.toString() == 'Renovation.${json['renovation'] as String}'),
      yearBuild: json['yearBuild'] == null ? null : json['yearBuild'] as int,
      ceilingHeight: json['ceilingHeight'] == null
          ? null
          : (json['ceilingHeight'] as int).toDouble(),
      elevator: json['elevator'] == null ? null : json['elevator'] as bool,
      parkingLot:
          json['parkingLot'] == null ? null : json['parkingLot'] as bool,
      description: json['description'] as String,
      balcony: json['balcony'] == null ? null : json['balcony'] as bool,
      furniture: json['furniture'] == null ? null : json['furniture'] as bool,
      kitchenFurniture: json['kitchenFurniture'] == null
          ? null
          : json['kitchenFurniture'] as bool,
      cableTv: json['cableTv'] == null ? null : json['cableTv'] as bool,
      phone: json['phone'] == null ? null : json['phone'] as bool,
      internet: json['internet'] == null ? null : json['internet'] as bool,
      electricity:
          json['electricity'] == null ? null : json['electricity'] as bool,
      gas: json['gas'] == null ? null : json['gas'] as bool,
      water: json['water'] == null ? null : json['water'] as bool,
      heating: json['heating'] == null ? null : json['heating'] as bool,
      tv: json['tv'] == null ? null : json['tv'] as bool,
      conditioner:
          json['conditioner'] == null ? null : json['conditioner'] as bool,
      washingMachine: json['washingMachine'] == null
          ? null
          : json['washingMachine'] as bool,
      dishwasher:
          json['dishwasher'] == null ? null : json['dishwasher'] as bool,
      refrigerator:
          json['refrigerator'] == null ? null : json['refrigerator'] as bool,
      kidsAllowed:
          json['kidsAllowed'] == null ? null : json['kidsAllowed'] as bool,
      petsAllowed:
          json['petsAllowed'] == null ? null : json['petsAllowed'] as bool,
      garage: json['garage'] == null ? null : json['garage'] as bool,
      pool: json['pool'] == null ? null : json['pool'] as bool,
      bathhouse: json['bathhouse'] == null ? null : json['bathhouse'] as bool,
      price: json['price'] as int,
      images: (json['images'] as List<dynamic>).cast<String>(),
    );
  }

  Post copyWith({
    UserType? userType,
    EstateType? estateType,
    ApartmentType? apartmentType,
    DealType? dealType,
    List<double>? location,
    Settlement? city,
    Settlement? district,
    Settlement? subdistrict,
    String? address,
    int? rooms,
    int? sqm,
    int? livingRoomsSqm,
    int? kitchenSqm,
    int? lotSqm,
    int? floor,
    int? totalFloors,
    bool? redevelopment,
    bool? documented,
    Renovation? renovation,
    int? yearBuild,
    double? ceilingHeight,
    bool? elevator,
    bool? parkingLot,
    String? description,
    bool? balcony,
    bool? furniture,
    bool? kitchenFurniture,
    bool? cableTv,
    bool? phone,
    bool? internet,
    bool? electricity,
    bool? gas,
    bool? water,
    bool? heating,
    bool? tv,
    bool? conditioner,
    bool? washingMachine,
    bool? dishwasher,
    bool? refrigerator,
    bool? kidsAllowed,
    bool? petsAllowed,
    bool? garage,
    bool? pool,
    bool? bathhouse,
    int? price,
    List<String>? images,
    int? step,
  }) {
    return Post(
      id: id,
      userType: userType ?? this.userType,
      estateType: estateType ?? this.estateType,
      apartmentType: (estateType ?? this.estateType) == EstateType.house
          ? null
          : apartmentType ?? this.apartmentType,
      dealType: dealType ?? this.dealType,
      location: location ?? this.location,
      city: city ?? this.city,
      district: district ?? this.district,
      subdistrict: subdistrict ?? this.subdistrict,
      address: address ?? this.address,
      rooms: rooms ?? this.rooms,
      sqm: sqm ?? this.sqm,
      livingRoomsSqm: livingRoomsSqm ?? this.livingRoomsSqm,
      kitchenSqm: kitchenSqm ?? this.kitchenSqm,
      lotSqm: (estateType ?? this.estateType) != EstateType.house
          ? null
          : lotSqm ?? this.lotSqm,
      floor: (estateType ?? this.estateType) != EstateType.apartment
          ? null
          : floor ?? this.floor,
      totalFloors: totalFloors ?? this.totalFloors,
      redevelopment: redevelopment ?? this.redevelopment,
      documented: documented ?? this.documented,
      renovation: renovation ?? this.renovation,
      yearBuild: yearBuild ?? this.yearBuild,
      ceilingHeight: ceilingHeight ?? this.ceilingHeight,
      elevator: elevator ?? this.elevator,
      parkingLot: parkingLot ?? this.parkingLot,
      description: description ?? this.description,
      balcony: balcony ?? this.balcony,
      furniture: furniture ?? this.furniture,
      kitchenFurniture: kitchenFurniture ?? this.kitchenFurniture,
      cableTv: cableTv ?? this.cableTv,
      phone: phone ?? this.phone,
      internet: internet ?? this.internet,
      electricity: electricity ?? this.electricity,
      gas: gas ?? this.gas,
      water: water ?? this.water,
      heating: heating ?? this.heating,
      tv: tv ?? this.tv,
      conditioner: conditioner ?? this.conditioner,
      washingMachine: washingMachine ?? this.washingMachine,
      dishwasher: dishwasher ?? this.dishwasher,
      refrigerator: refrigerator ?? this.refrigerator,
      kidsAllowed: (dealType ?? this.dealType) == DealType.sale
          ? null
          : kidsAllowed ?? this.kidsAllowed,
      petsAllowed: (dealType ?? this.dealType) == DealType.sale
          ? null
          : petsAllowed ?? this.petsAllowed,
      garage: (estateType ?? this.estateType) != EstateType.house
          ? null
          : garage ?? this.garage,
      pool: (estateType ?? this.estateType) != EstateType.house
          ? null
          : pool ?? this.pool,
      bathhouse: (estateType ?? this.estateType) != EstateType.house
          ? null
          : bathhouse ?? this.bathhouse,
      price: price ?? this.price,
      images: images ?? this.images,
      step: step ?? this.step,
    );
  }
}
