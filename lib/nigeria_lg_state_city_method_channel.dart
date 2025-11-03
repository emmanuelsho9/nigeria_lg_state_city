import 'dart:convert';
import 'package:flutter/services.dart';
import 'nigeria_lg_state_city_platform_interface.dart';

class NigeriaLgStateCityMethodChannel implements NigeriaLgStateCityPlatform {
 

static const String _assetPath = 'packages/nigeria_lg_state_city/assets/'; 
  @override
  Future<List<dynamic>> getStates() async {
    final data = await rootBundle.loadString('${_assetPath}states.json');
    return jsonDecode(data) as List<dynamic>;
  }

  @override
  Future<List<dynamic>> getLGAs(String stateId) async {
    final data = await rootBundle.loadString('${_assetPath}lgas.json');
    final List<dynamic> all = jsonDecode(data);
    return all.where((lga) => lga['stateId'] == stateId).toList();
  }

// nigeria_lg_state_city_method_channel.dart
@override
Future<List<dynamic>> getCities(String lgaId) async {
  final data = await rootBundle.loadString('${_assetPath}cities.json');
  final List<dynamic> all = jsonDecode(data);
  return all.where((city) => city['stateId'] == lgaId).toList();
}
}