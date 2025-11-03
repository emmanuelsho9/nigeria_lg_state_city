import 'package:flutter/material.dart';

typedef ItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool isSelected);
typedef DropdownBuilder =
    Widget Function(BuildContext context, String? hint, Widget? child);

/// A fully generic, customizable dropdown that works with any type [T].
class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool isLoading;
  final ItemBuilder<T> itemBuilder;
  final DropdownBuilder? dropdownBuilder;
  final InputDecoration? decoration;
  final bool isExpanded;
  final AlignmentGeometry alignment;
  final bool enabled;
  final VoidCallback? onTap; // called when the field itself is tapped

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.isLoading = false,
    required this.itemBuilder,
    this.dropdownBuilder,
    this.decoration,
    this.isExpanded = true,
    required this.alignment,
    this.enabled = true,
    this.onTap,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}
class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  List<T> _uniqueItems() {
    final seen = <T>{};
    return widget.items.where((e) => seen.add(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.isLoading
        ? const Text('Loading...')
        : (widget.hint != null ? Text(widget.hint!) : null);

    final validValue = widget.items.contains(widget.value) ? widget.value : null;

    final dropdown = DropdownButtonFormField<T>(
      value: validValue,                     // ← **controlled**
      isExpanded: widget.isExpanded,
      hint: effectiveHint,
      decoration: widget.decoration ??
          const InputDecoration(border: OutlineInputBorder()),
      onChanged: widget.isLoading || !widget.enabled ? null : widget.onChanged,
      onTap: widget.onTap,
      items: _uniqueItems().map((item) {
        final isSelected = item == validValue;
        return DropdownMenuItem<T>(
          value: item,
          alignment: widget.alignment,
          child: widget.itemBuilder(context, item, isSelected),
        );
      }).toList(),
    );

    return widget.dropdownBuilder != null
        ? widget.dropdownBuilder!(context, widget.hint, dropdown)
        : dropdown;
  }
}

// controller.dart
class StateLgaCityController extends ChangeNotifier {
  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedLga;
  Map<String, dynamic>? _selectedCity;

  Map<String, dynamic>? get selectedState => _selectedState;
  Map<String, dynamic>? get selectedLga => _selectedLga;
  Map<String, dynamic>? get selectedCity => _selectedCity;

  void selectState(Map<String, dynamic>? state) {
    if (_selectedState?['id'] != state?['id']) {
      _selectedState = state;
      _selectedLga = null;
      _selectedCity = null;
      notifyListeners();
    }
  }

  void selectLga(Map<String, dynamic>? lga) {
    if (_selectedLga?['id'] != lga?['id']) {
      _selectedLga = lga;
      _selectedCity = null; // reset city when LGA changes
      notifyListeners();
    }
  }

  void selectCity(Map<String, dynamic>? city) {
    if (_selectedCity?['id'] != city?['id']) {
      _selectedCity = city;
      notifyListeners();
    }
  }
}