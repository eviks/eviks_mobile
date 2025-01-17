import 'dart:convert';

import 'package:eviks_mobile/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/address.dart';
import '../models/address_not_found.dart';
import '../models/failure.dart';
import '../models/settlement.dart';

class Localities with ChangeNotifier {
  Future<Map<String, dynamic>> getAddressByCoords(
    Map<String, dynamic> body,
  ) async {
    final url = Uri(
      scheme: baseScheme,
      host: baseHost,
      port: basePort,
      path: '/api/localities/getAddressByCoords',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
          data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
          '\n',
        );
        throw Failure(buffer.toString(), response.statusCode);
      }

      final dynamic data = json.decode(response.body);

      String cityName = '';
      String districtName = '';
      String subdistrictName = '';
      String address = '';

      if (data['success'] == true) {
        data['addr_components'].forEach((addressComponent) async {
          if (addressComponent['type'] == 'country district') {
            cityName = addressComponent['name'] as String;
          }
          if (addressComponent['type'] == 'settlement district') {
            districtName = addressComponent['name'] as String;
          }
          if (addressComponent['type'] == 'settlement') {
            subdistrictName = addressComponent['name'] as String;
          }
          if (addressComponent['type'] == 'street') {
            address = addressComponent['name'] as String;
          }
        });
      }

      if (cityName.isEmpty) {
        throw AddressNotFound();
      }

      Settlement city;
      Settlement? district;
      Settlement? subdistrict;

      // City
      final result = await getLocalities({'name': cityName, 'type': '2'});
      city = result[0];

      // District
      if (districtName.isNotEmpty) {
        district = city.children
            ?.firstWhere((element) => element.name == districtName);
        if (district != null) {
          final result = await getLocalities({'id': district.id});
          district = result[0];
        }
      }

      // Subdistrict
      if (subdistrictName.isNotEmpty && district != null) {
        subdistrict = district.children
            ?.firstWhere((element) => element.name == subdistrictName);
      } else if (district?.children?.length == 1) {
        subdistrict = district?.children![0];
      }

      return {
        'city': city,
        'district': district,
        'subdistrict': subdistrict,
        'address': address,
      };
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Address>> geocoder(String text, List<double> location) async {
    final url = Uri(
      scheme: baseScheme,
      host: baseHost,
      port: basePort,
      path: 'api/localities/geocoder',
      queryParameters: {
        'q': text,
        'lon': location[0].toString(),
        'lat': location[1].toString(),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
          data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
          '\n',
        );
        throw Failure(buffer.toString(), response.statusCode);
      }

      final List<Address> addresses = [];

      final dynamic data = json.decode(response.body);
      data['rows'].forEach((element) {
        addresses.add(Address.fromJson(element));
      });

      return addresses;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Settlement>> getLocalities(
    Map<String, String> queryParameters,
  ) async {
    final url = Uri(
      scheme: baseScheme,
      host: baseHost,
      port: basePort,
      path: 'api/localities',
      queryParameters: queryParameters,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 500) {
        throw Failure('Server error', response.statusCode);
      } else if (response.statusCode != 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final buffer = StringBuffer();
        buffer.writeAll(
          data['errors'].map((error) => error['msg']) as Iterable<dynamic>,
          '\n',
        );
        throw Failure(buffer.toString(), response.statusCode);
      }

      final List data = json.decode(response.body) as List;
      final settlements =
          data.map((element) => Settlement.fromJson(element)).toList();

      return settlements;
    } catch (error) {
      rethrow;
    }
  }
}
