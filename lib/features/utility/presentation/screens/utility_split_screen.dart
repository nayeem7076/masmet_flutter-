import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';

class UtilitySplitScreen extends ConsumerStatefulWidget {
  const UtilitySplitScreen({super.key});

  @override
  ConsumerState<UtilitySplitScreen> createState() => _UtilitySplitScreenState();
}

class _UtilitySplitScreenState extends ConsumerState<UtilitySplitScreen> {
  final TextEditingController _gasController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  double _gasTotal = 0;
  double _currentTotal = 0;

  @override
  void initState() {
    super.initState();
    final p = ref.read(appProviderProvider);
    _gasTotal = p.gasBill;
    _currentTotal = p.currentBill;
    _gasController.text = _gasTotal == 0 ? '' : _gasTotal.toStringAsFixed(0);
    _currentController.text =
        _currentTotal == 0 ? '' : _currentTotal.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _gasController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final gas = double.tryParse(_gasController.text.trim()) ?? 0;
    final current = double.tryParse(_currentController.text.trim()) ?? 0;
    await ref.read(appProviderProvider).setUtilityBills(
          gas: gas,
          current: current,
        );
    if (!mounted) return;
    setState(() {
      _gasTotal = gas;
      _currentTotal = current;
    });
  }

  String _money(double value) => '৳${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appProviderProvider);
    final members = provider.members;
    final count = members.length;
    final double utilityTotal = _gasTotal + _currentTotal;
    final double perHeadGas = count == 0 ? 0 : _gasTotal / count.toDouble();
    final double perHeadCurrent =
        count == 0 ? 0 : _currentTotal / count.toDouble();
    final double perHeadTotal = perHeadGas + perHeadCurrent;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF183153),
        title: Text(AppText.t(context, bn: 'ইউটিলিটি ভাগ', en: 'Utility Split')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    size: 20,
                    color: Color(0xFF2F5DFF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppText.t(
                      context,
                      bn: 'বিল দিন, সাথে সাথে member-wise ভাগ দেখুন',
                      en: 'Enter bills to see instant member-wise split',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _billInputCard(
            context: context,
            titleBn: 'গ্যাস বিল',
            titleEn: 'Gas Bill',
            icon: Icons.local_fire_department_rounded,
            controller: _gasController,
            accent: const Color(0xFFFF7A00),
          ),
          const SizedBox(height: 10),
          _billInputCard(
            context: context,
            titleBn: 'কারেন্ট বিল',
            titleEn: 'Current Bill',
            icon: Icons.bolt_rounded,
            controller: _currentController,
            accent: const Color(0xFF175CD3),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF183153),
            ),
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_rounded),
            label: Text(AppText.t(context, bn: 'হিসাব দেখুন', en: 'Calculate')),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.65,
            children: [
              _summaryTile('Gas', _money(_gasTotal), const Color(0xFFFFF2E8), const Color(0xFFFF7A00)),
              _summaryTile('Current', _money(_currentTotal), const Color(0xFFEAF0FF), const Color(0xFF175CD3)),
              _summaryTile('Total', _money(utilityTotal), const Color(0xFFECFDF3), const Color(0xFF12B76A)),
              _summaryTile(
                AppText.t(context, bn: 'প্রতি জনে', en: 'Per Member'),
                _money(perHeadTotal),
                const Color(0xFFF4EBFF),
                const Color(0xFF7A3EF5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (members.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  AppText.t(
                    context,
                    bn: 'কোনো মেম্বার নেই। আগে মেম্বার যোগ করুন।',
                    en: 'No members found. Add members first.',
                  ),
                ),
              ),
            )
          else
            ...members.map(
              (m) => Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFEAF0FF),
                    ),
                    child: m.imagePath != null && m.imagePath!.trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(m.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _initialAvatar(m.name),
                            ),
                          )
                        : _initialAvatar(m.name),
                  ),
                  title: Text(m.name),
                  subtitle: Text(
                    'Gas ${_money(perHeadGas)} + Current ${_money(perHeadCurrent)}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF183153),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _money(perHeadTotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _billInputCard({
    required BuildContext context,
    required String titleBn,
    required String titleEn,
    required IconData icon,
    required TextEditingController controller,
    required Color accent,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 8),
                Text(
                  AppText.t(context, bn: titleBn, en: titleEn),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '৳ ',
                hintText: AppText.t(context, bn: 'মোট বিল লিখুন', en: 'Enter total bill'),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9E5FF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(
    String label,
    String value,
    Color bg,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF344054),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialAvatar(String name) {
    final initial = name.trim().isEmpty ? 'M' : name.trim()[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF2F5DFF),
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
