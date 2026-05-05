import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  final TextEditingController _breakfastController =
      TextEditingController(text: '0');
  final TextEditingController _lunchController =
      TextEditingController(text: '1');
  final TextEditingController _dinnerController =
      TextEditingController(text: '1');

  String _selectedMemberId = '';

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(appProviderProvider);

    if (_selectedMemberId.isEmpty && p.members.isNotEmpty) {
      _selectedMemberId = p.members.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Entry')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (p.isManager)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value:
                          _selectedMemberId.isEmpty ? null : _selectedMemberId,
                      decoration: const InputDecoration(labelText: 'Member'),
                      items: p.members
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m.id,
                              child: Text(m.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedMemberId = v ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _breakfastController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Breakfast'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _lunchController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Lunch'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _dinnerController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Dinner'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _selectedMemberId.isEmpty
                          ? null
                          : () {
                              p.addMeal(
                                _selectedMemberId,
                                double.tryParse(_breakfastController.text) ?? 0,
                                double.tryParse(_lunchController.text) ?? 0,
                                double.tryParse(_dinnerController.text) ?? 0,
                              );
                            },
                      child: const Text('Add Meal'),
                    ),
                  ],
                ),
              ),
            ),
          ...p.meals.reversed.map((m) {
            final matches = p.members.where((x) => x.id == m.memberId);
            final mem = matches.isEmpty ? null : matches.first;

            return Card(
              child: ListTile(
                title: Text(mem?.name ?? 'Unknown'),
                subtitle: Text(
                  'Breakfast ${m.breakfast}, Lunch ${m.lunch}, Dinner ${m.dinner}',
                ),
                trailing: p.isManager
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => p.deleteMeal(m.id),
                      )
                    : Text('Total ${m.total}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
