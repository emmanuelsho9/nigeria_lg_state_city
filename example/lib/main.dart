import 'package:flutter/material.dart';

import 'package:nigeria_lg_state_city/const.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';
void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  final controller = StateLgaCityController();

   MyApp({super.key});

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
                  final state = controller.selectedState?['name'] ?? '-';
                  final lga = controller.selectedLga?['name'] ?? '-';
                  final city = controller.selectedCity?['name'] ?? '-';
                  return Text(
                    'Selected: $state → $lga → $city',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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