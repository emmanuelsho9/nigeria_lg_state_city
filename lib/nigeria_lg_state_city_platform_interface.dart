// nigeria_lg_state_city_platform_interface.dart
abstract class NigeriaLgStateCityPlatform {
  Future<List<dynamic>> getStates();
  Future<List<dynamic>> getLGAs(String stateId);
  Future<List<dynamic>> getCities(String lgaId); // ← NEW
}