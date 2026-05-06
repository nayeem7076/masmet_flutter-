import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:messmate_app_full/core/localization/app_text.dart';
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
      appBar: AppBar(
        title: Text(AppText.t(context, bn: 'মিল এন্ট্রি', en: 'Meal Entry')),
      ),
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
                      decoration: InputDecoration(
                        labelText:
                            AppText.t(context, bn: 'মেম্বার', en: 'Member'),
                      ),
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
                            decoration: InputDecoration(
                              labelText: AppText.t(context,
                                  bn: 'সকাল', en: 'Breakfast'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _lunchController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  AppText.t(context, bn: 'দুপুর', en: 'Lunch'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _dinnerController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  AppText.t(context, bn: 'রাত', en: 'Dinner'),
                            ),
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
                      child: Text(AppText.t(context,
                          bn: 'মিল যোগ করুন', en: 'Add Meal')),
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
                title: Text(mem?.name ??
                    AppText.t(context, bn: 'অজানা', en: 'Unknown')),
                subtitle: Text(
                  '${AppText.t(context, bn: 'সকাল', en: 'Breakfast')} ${m.breakfast}, ${AppText.t(context, bn: 'দুপুর', en: 'Lunch')} ${m.lunch}, ${AppText.t(context, bn: 'রাত', en: 'Dinner')} ${m.dinner}',
                ),
                trailing: p.isManager
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => p.deleteMeal(m.id),
                      )
                    : Text(
                        '${AppText.t(context, bn: 'মোট', en: 'Total')} ${m.total}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
