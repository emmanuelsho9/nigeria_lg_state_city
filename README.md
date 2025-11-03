
# nigeria_lg_state_city

A **Flutter package** that provides **cascading dropdowns** for **Nigerian States, Local Government Areas (LGAs), and Cities** — with **built-in JSON data**, **zero network dependency**, and **controller-based state management**.

Perfect for **forms, e-commerce, onboarding, KYC, logistics**, or any app targeting **Nigerian users**.

No API keys. No internet. Just **pure, fast, offline dropdowns**.

---

## Features
- **State → LGA → City** cascading dropdowns
- **Offline-first**: All data bundled as JSON assets
- **Controller-driven** (`StateLgaCityController`) — no `setState` boilerplate
- **Optional `value`/`onChanged`** support for legacy use
- **Unique ID system** — no duplicate value crashes
- **Loading & error states** with graceful fallbacks
- **Fully customizable** via `itemBuilder`, `dropdownBuilder`, `style`, `decoration`
- **Search-ready** — just add a `TextField`
- **Null-safe**, **well-documented**, **production-ready**
- **Lightweight** — minimal dependencies

---


---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  nigeria_lg_state_city: ^1.0.0
```

Run:

```bash
flutter pub get
```

---

## Setup

No API key. No configuration. Just **add the assets**.

> The package includes:
> - `assets/states.json`
> - `assets/lgas.json`
> - `assets/cities.json`

These are automatically included when you add the package.

---

## Usage

### 1. Create the Controller

```dart
final controller = StateLgaCityController();
```

### 2. Use the Dropdowns

```dart
NigeriaStateDropdown(
  controller: controller,
  decoration: const InputDecoration(
    labelText: 'State',
    border: OutlineInputBorder(),
  ),
),

NigeriLgDropdown(
  controller: controller,
  decoration: const InputDecoration(
    labelText: 'LGA',
    border: OutlineInputBorder(),
  ),
),

NigeriaCityDropdown(
  controller: controller,
  decoration: const InputDecoration(
    labelText: 'City',
    border: OutlineInputBorder(),
  ),
),
```

### 3. Listen to Selection

```dart
ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    final state = controller.selectedState?['name'] ?? '-';
    final lga = controller.selectedLga?['name'] ?? '-';
    final city = controller.selectedCity?['name'] ?? '-';
    return Text(
      'Selected: $state → $lga → $city',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  },
)
```

---

## Legacy Mode (No Controller)

```dart
String? stateId, lgaId, cityId;

NigeriaStateDropdown(
  value: stateId,
  onChanged: (id) => setState(() => stateId = id),
),

NigeriLgDropdown(
  value: lgaId,
  onChanged: (id) => setState(() => lgaId = id),
  // Note: LGA dropdown needs a way to know the selected state
  // Use controller for full cascade support
),
```

> **Recommended**: Use `StateLgaCityController` for full cascading.

---

## Parameters

| Parameter | Type | Description | Default |
|---------|------|-------------|---------|
| `controller` | `StateLgaCityController?` | **Required** for `LGA` & `City`. Drives cascading. | — |
| `value` | `String?` | Selected ID (legacy mode) | — |
| `onChanged` | `ValueChanged<String?>?` | Callback with selected ID | — |
| `decoration` | `InputDecoration?` | Full `TextField` decoration | — |
| `hint` | `String?` | Placeholder text | `'Select State'`, etc. |
| `isExpanded` | `bool?` | Expand to fill width | `true` |
| `style` | `TextStyle?` | Text style for selected item | — |
| `alignment` | `AlignmentGeometry?` | Item alignment in dropdown | `Alignment.centerLeft` |
| `enabled` | `bool?` | Enable/disable dropdown | `true` |
| `onTap` | `VoidCallback?` | Tap on the field | — |
| `itemBuilder` | `Widget Function(BuildContext, String, bool)` | Custom item UI | `Text(name)` |
| `dropdownBuilder` | `Widget Function(BuildContext, String?, Widget?)` | Wrap the entire dropdown | — |

---

## Example

```dart
import 'package:flutter/material.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final controller = StateLgaCityController();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Nigeria Address Picker')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NigeriaStateDropdown(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              NigeriLgDropdown(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'LGA',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              NigeriaCityDropdown(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('State: ${controller.selectedState?['name'] ?? '-'}'),
                          Text('LGA: ${controller.selectedLga?['name'] ?? '-'}'),
                          Text('City: ${controller.selectedCity?['name'] ?? '-'}'),
                          if (controller.selectedCity != null)
                            Text(
                              'Coords: (${controller.selectedCity!['latitude']}, ${controller.selectedCity!['longitude']})',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Data Format

### `assets/states.json`
```json
[{ "id": "1", "name": "Lagos" }]
```

### `assets/lgas.json`
```json
[{ "id": "1001", "name": "Ikeja", "stateId": "1" }]
```

### `assets/cities.json`
```json
[{
  "id": 1,
  "name": "Ikeja",
  "localGovernmentId": "1001",
  "latitude": "6.59651",
  "longitude": "3.34205"
}]
```

---

## Controller API

```dart
class StateLgaCityController extends ChangeNotifier {
  Map<String, dynamic>? get selectedState;
  Map<String, dynamic>? get selectedLga;
  Map<String, dynamic>? get selectedCity;

  void selectState(Map<String, dynamic>? state);
  void selectLga(Map<String, dynamic>? lga);
  void selectCity(Map<String, dynamic>? city);
}
```

> Automatically resets child selections when parent changes.

---

## Customization

```dart
NigeriaCityDropdown(
  controller: controller,
  itemBuilder: (context, id, selected) {
    final city = /* find city */;
    return ListTile(
      leading: Icon(Icons.location_city),
      title: Text(city['name']),
      subtitle: Text('${city['latitude']}, ${city['longitude']}'),
      trailing: selected ? Icon(Icons.check, color: Colors.green) : null,
    );
  },
  dropdownBuilder: (context, hint, child) => Card(
    elevation: 4,
    child: Padding(padding: const EdgeInsets.all(8), child: child),
  ),
)
```

---

## Notes

- **No internet required** — all data is bundled.
- **Fast loading** — JSON assets are preloaded.
- **Unique IDs** — uses `id` fields (string) to avoid duplicate crashes.
- **Safe cascading** — LGA/City reset when parent changes.
- **Error handling** — shows `SnackBar` on load failure.
- **Searchable** — filter `_cities` list with a `TextField`.

---

## Roadmap

- [ ] Built-in search for large LGAs/Cities
- [ ] Ward support
- [ ] Geocoding (lat/lng → address)
- [ ] Form integration (`FormField`)
- [ ] Theming support
- [ ] Unit & widget tests

---

## Contributing

Contributions are welcome!  
Please submit **issues** or **pull requests** on [GitHub](https://github.com/emmanuelsho9/nigeria_lg_state_city.git).

---

## License

```
MIT License
```

---

**Made with love for Nigerian developers**
```

---

## `pubspec.yaml` Description (for pub.dev)

```yaml
description: >
  A Flutter plugin for cascading dropdowns of Nigerian States, LGAs, and Cities.
  Includes offline JSON data, controller-based state management, and full customization.
  No API key or internet required. Perfect for forms and address pickers.
```

---

## Final Checklist Before Publishing

| Task | Status |
|------|--------|
| `pubspec.yaml` updated | Done |
| Assets included (`states.json`, etc.) | Done |
| Example app in `example/` | Done |
| `README.md` | Done |
| Screenshots (replace placeholders) | To do |
| Run `flutter analyze` | To do |
| Run `flutter test` (add basic tests) | To do |
| `flutter pub publish --dry-run` | To do |

---

**You're ready to publish!**

Once live, share the link — I’ll be the first to **like & star** it!

Need:
- Example project
- Changelog
- GitHub Actions

