import 'package:flutter/material.dart';
import 'package:nigeria_lg_state_city/const.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city_method_channel.dart';
// nigeria_state_dropdown.dart
class NigeriaStateDropdown extends StatefulWidget {
  final String? value;                     // optional external value (ID)
  final ValueChanged<String?>? onChanged; // optional external callback
  final InputDecoration? decoration;
  final String? hint;
  final bool? isExpanded;
  final TextStyle? style;
  final AlignmentGeometry? alignment;
  final bool? enabled;
  final VoidCallback? onTap;
  final Widget Function(BuildContext, String?, Widget?)? dropdownBuilder;
  final StateLgaCityController? controller;    // ← **the new way**

  const NigeriaStateDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.decoration,
    this.hint,
    this.dropdownBuilder,
    this.isExpanded,
    this.style,
    this.alignment,
    this.enabled,
    this.onTap,
    this.controller,
  });

  @override
  State<NigeriaStateDropdown> createState() => _NigeriaStateDropdownState();
}

class _NigeriaStateDropdownState extends State<NigeriaStateDropdown> {
  final _platform = NigeriaLgStateCityMethodChannel();
  List<Map<String, dynamic>> _states = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => _loading = true);
    try {
      final raw = (await _platform.getStates())
          .cast<Map<String, dynamic>>();

      raw.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));

      setState(() {
        _states = raw;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('States: $e')));
      }
      setState(() => _loading = false);
    }
  }

  // --------------------------------------------------------------
  //  Helper: decide which value to show (controller wins)
  // --------------------------------------------------------------
  String? _effectiveValue() {
    if (widget.controller?.selectedState != null) {
      return widget.controller!.selectedState!['id'].toString();
    }
    return widget.value;
  }

  // --------------------------------------------------------------
  //  Helper: fire the right callback(s)
  // --------------------------------------------------------------
  void _onSelect(String? id) {
    final selectedMap = _states.firstWhere(
      (m) => m['id'].toString() == id,
      orElse: () => <String, dynamic>{},
    );

    // 1. Controller path
    widget.controller?.selectState(selectedMap.isEmpty ? null : selectedMap);

    // 2. Legacy path
    widget.onChanged?.call(selectedMap.isEmpty ? null : id);
  }

  @override
  Widget build(BuildContext context) {
    // IDs are unique → safe for DropdownButtonFormField
    final ids = _states.map((m) => m['id'].toString()).toList();

    return ListenableBuilder(
      listenable: widget.controller ?? ChangeNotifier(),
      builder: (context, _) {
        return CustomDropdown<String>(
          items: ids,
          value: _effectiveValue(),
          onChanged: _loading ? null : _onSelect,
          isLoading: _loading,
          hint: widget.hint ?? 'Select State',
          decoration: widget.decoration,
          dropdownBuilder: widget.dropdownBuilder,
          isExpanded: widget.isExpanded ?? true,
          itemBuilder: (ctx, id, selected) {
            final name = _states
                    .firstWhere((m) => m['id'].toString() == id,
                        orElse: () => {'name': id})['name'] as String? ??
                '???';
            return Text(
              name,
              style: widget.style ??
                  TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.blue : null,
                  ),
            );
          },
          alignment: widget.alignment ?? Alignment.centerLeft,
          enabled: widget.enabled ?? true,
          onTap: widget.onTap,
        );
      },
    );
  }
}
// nigeria_lga_dropdown.dart
class NigeriLgDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final InputDecoration? decoration;
  final String? hint;
  final bool? isExpanded;
  final TextStyle? style;
  final AlignmentGeometry? alignment;
  final bool? enabled;
  final VoidCallback? onTap;
  final Widget Function(BuildContext, String?, Widget?)? dropdownBuilder;
  final StateLgaCityController controller;

  const NigeriLgDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.decoration,
    this.hint,
    this.dropdownBuilder,
    this.isExpanded,
    this.style,
    this.alignment,
    this.enabled,
    this.onTap,
   required this.controller,
  });

  @override
  State<NigeriLgDropdown> createState() => _NigeriLgDropdownState();
}

class _NigeriLgDropdownState extends State<NigeriLgDropdown> {
  final _platform = NigeriaLgStateCityMethodChannel();
  List<Map<String, dynamic>> _lgas = [];
  bool _loading = true;
  String? _lastStateId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_reactToStateChange);
    _reactToStateChange(); // initial load
  }

  @override
  void dispose() {
    widget.controller.removeListener(_reactToStateChange);
    super.dispose();
  }

  void _reactToStateChange() {
    final state = widget.controller.selectedState;
    final stateId = state?['id']?.toString();

    if (stateId == null) {
      setState(() {
        _lgas.clear();
        _loading = false;
        _lastStateId = null;
      });
      return;
    }

    if (stateId == _lastStateId) return;

    setState(() {
      _lgas.clear();
      _loading = true;
    });
    _loadLGAs(stateId);
  }

  Future<void> _loadLGAs(String stateId) async {
    try {
      final raw = (await _platform.getLGAs(stateId))
          .cast<Map<String, dynamic>>();

      raw.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));

      if (!mounted) return;

      setState(() {
        _lgas = raw;
        _lastStateId = stateId;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('LGAs: $e')));
        setState(() => _loading = false);
      }
    }
  }

  String? _effectiveValue() {
    if (widget.controller.selectedLga != null) {
      return widget.controller.selectedLga!['id'].toString();
    }
    return widget.value;
  }

  void _onSelect(String? id) {
    final selectedMap = _lgas.firstWhere(
      (m) => m['id'].toString() == id,
      orElse: () => <String, dynamic>{},
    );

    widget.controller.selectLga(selectedMap.isEmpty ? null : selectedMap);
    widget.onChanged?.call(selectedMap.isEmpty ? null : id);
  }

  @override
  Widget build(BuildContext context) {
    final ids = _lgas.map((m) => m['id'].toString()).toList();

    return ListenableBuilder(
      listenable: widget.controller ,
      builder: (context, _) {
        return CustomDropdown<String>(
          items: ids,
          value: _effectiveValue(),
          onChanged: _loading ? null : _onSelect,
          isLoading: _loading,
          hint: widget.hint ?? 'Select LGA',
          decoration: widget.decoration,
          dropdownBuilder: widget.dropdownBuilder,
          isExpanded: widget.isExpanded ?? true,
          itemBuilder: (ctx, id, selected) {
            final name = _lgas
                    .firstWhere((m) => m['id'].toString() == id,
                        orElse: () => {'name': id})['name'] as String? ??
                '???';
            return Text(
              name,
              style: widget.style ??
                  TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.blue : null,
                  ),
            );
          },
          alignment: widget.alignment ?? Alignment.centerLeft,
          enabled: widget.enabled ?? true,
          onTap: widget.onTap,
        );
      },
    );
  }
}


class NigeriaCityDropdown extends StatefulWidget {
  final String? value;                     // city ID (String)
  final ValueChanged<String?>? onChanged;
  final InputDecoration? decoration;
  final String? hint;
  final bool? isExpanded;
  final TextStyle? style;
  final AlignmentGeometry? alignment;
  final bool? enabled;
  final VoidCallback? onTap;
  final Widget Function(BuildContext, String?, Widget?)? dropdownBuilder;
  final StateLgaCityController controller;

  const NigeriaCityDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.decoration,
    this.hint,
    this.dropdownBuilder,
    this.isExpanded,
    this.style,
    this.alignment,
    this.enabled,
    this.onTap,
   required this.controller,
  });

  @override
  State<NigeriaCityDropdown> createState() => _NigeriaCityDropdownState();
}

class _NigeriaCityDropdownState extends State<NigeriaCityDropdown> {
  final _platform = NigeriaLgStateCityMethodChannel();
  List<Map<String, dynamic>> _cities = [];
  bool _loading = true;
  String? _lastLgaId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onLgaChanged);
    _onLgaChanged(); // initial load
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLgaChanged);
    super.dispose();
  }

  void _onLgaChanged() {
    final lga = widget.controller.selectedState;
    final lgaId = lga?['id']?.toString();

    // No LGA selected → clear cities
    if (lgaId == null) {
      setState(() {
        _cities.clear();
        _loading = false;
        _lastLgaId = null;
      });
      return;
    }

    // Same LGA → no reload
    if (lgaId == _lastLgaId) return;

    setState(() {
      _cities.clear();
      _loading = true;
    });
    _loadCities(lgaId);
  }

  Future<void> _loadCities(String lgaId) async {
    try {
      final raw = (await _platform.getCities(lgaId))
          .cast<Map<String, dynamic>>();

      // Sort alphabetically by name
      raw.sort((a, b) {
        final aName = (a['name'] as String?) ?? '';
        final bName = (b['name'] as String?) ?? '';
        return aName.toLowerCase().compareTo(bName.toLowerCase());
      });

      if (!mounted) return;

      setState(() {
        _cities = raw;
        _lastLgaId = lgaId;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load cities: $e')));
        setState(() => _loading = false);
      }
    }
  }

  // Resolve value: controller > widget.value
  String? _effectiveValue() {
    if (widget.controller.selectedCity != null) {
      return widget.controller.selectedCity!['id'].toString();
    }
    return widget.value;
  }

  void _onSelect(String? cityId) {
    final selectedMap = _cities.firstWhere(
      (c) => c['id'].toString() == cityId,
      orElse: () => <String, dynamic>{},
    );

    widget.controller.selectCity(selectedMap.isEmpty ? null : selectedMap);
    widget.onChanged?.call(selectedMap.isEmpty ? null : cityId);
  }

  @override
  Widget build(BuildContext context) {
    final cityIds = _cities.map((c) => c['id'].toString()).toList();

    return ListenableBuilder(
      listenable: widget.controller ,
      builder: (context, _) {
        return CustomDropdown<String>(
          items: cityIds,
          value: _effectiveValue(),
          onChanged: _loading ? null : _onSelect,
          isLoading: _loading,
          hint: widget.hint ?? 'Select City',
          decoration: widget.decoration,
          dropdownBuilder: widget.dropdownBuilder,
          isExpanded: widget.isExpanded ?? true,
          itemBuilder: (ctx, id, isSelected) {
            final city = _cities.firstWhere(
              (c) => c['id'].toString() == id,
              orElse: () => {'name': 'Unknown'},
            );
            final name = city['name'] as String? ?? 'Unknown';

            return Text(
              name,
              style: widget.style ??
                  TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : null,
                  ),
            );
          },
          alignment: widget.alignment ?? Alignment.centerLeft,
          enabled: widget.enabled ?? true,
          onTap: widget.onTap,
        );
      },
    );
  }
}