import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:messmate_app_full/core/ui/ui_feedback.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/members/data/models/member.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  Future<String?> _pickMemberImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return null;
      if (kIsWeb) return picked.path;

      // Persist a private copy so image does not disappear after cache cleanup.
      final sourceFile = File(picked.path);
      if (!await sourceFile.exists()) return null;
      final dir = await getApplicationDocumentsDirectory();
      final membersDir = Directory('${dir.path}/member_images');
      if (!await membersDir.exists()) {
        await membersDir.create(recursive: true);
      }
      final ext =
          picked.path.contains('.') ? picked.path.split('.').last : 'jpg';
      final targetPath =
          '${membersDir.path}/member_${DateTime.now().microsecondsSinceEpoch}.$ext';
      final copied = await sourceFile.copy(targetPath);
      return copied.path;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image picker error: $e\nApp completely restart kore abar try korun.',
          ),
        ),
      );
      return null;
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(date);

  Future<void> _openDialer(BuildContext context, String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone dialer খুলতে পারিনি।')),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member'),
        content: const Text('Are you sure you want to delete this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showPaymentHistory(BuildContext context, Member member) async {
    final history = member.paymentHistory.reversed.toList();
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 540),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child:
                            Icon(Icons.payments_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${member.name} Payment History',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${history.length} entries',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No payment history yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                if (history.isNotEmpty)
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final payment = history[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F8FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD7E8FF)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formatDateTime(payment.paidAt),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F7ED),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Tk ${payment.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF1D8B4F),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openForm(BuildContext context, WidgetRef ref, [Member? m]) {
    final formKey = GlobalKey<FormState>();
    var autoValidateMode = AutovalidateMode.disabled;
    final name = TextEditingController(text: m?.name ?? '');
    final email = TextEditingController(text: m?.email ?? '');
    final phone = TextEditingController(text: m?.phone ?? '');
    final paid = TextEditingController(text: (m?.paidAmount ?? 0).toString());
    var selectedImagePath = m?.imagePath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Form(
            key: formKey,
            autovalidateMode: autoValidateMode,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child:
                              Icon(Icons.person_add_alt_1, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          m == null ? 'Add Member' : 'Edit Member',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedPath = await _pickMemberImage(context);
                            if (pickedPath == null) return;
                            setDialogState(() {
                              selectedImagePath = pickedPath;
                            });
                          },
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: const Color(0xFFE6F0FF),
                            backgroundImage: selectedImagePath != null &&
                                    selectedImagePath!.isNotEmpty &&
                                    !kIsWeb
                                ? FileImage(File(selectedImagePath!))
                                : null,
                            child: selectedImagePath == null ||
                                    selectedImagePath!.isEmpty
                                ? const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Color(0xFF1565C0),
                                    size: 28,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () async {
                            if (selectedImagePath == null ||
                                selectedImagePath!.isEmpty) {
                              final pickedPath =
                                  await _pickMemberImage(context);
                              if (pickedPath == null) return;
                              setDialogState(() {
                                selectedImagePath = pickedPath;
                              });
                              return;
                            }
                            setDialogState(() {
                              selectedImagePath = null;
                            });
                          },
                          child: Text(
                            selectedImagePath == null ||
                                    selectedImagePath!.isEmpty
                                ? 'Add Photo'
                                : 'Remove Photo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: name,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Member name is required.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Member Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: email,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Email is required.';
                      if (!text.contains('@') || !text.contains('.')) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phone,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Phone number is required.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: paid,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Paid amount is required.';
                      final amount = double.tryParse(text);
                      if (amount == null || amount < 0) {
                        return 'Paid amount must be a valid number.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Advance/Paid Amount',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final isValid =
                                formKey.currentState?.validate() ?? false;
                            if (!isValid) {
                              setDialogState(() {
                                autoValidateMode = AutovalidateMode.always;
                              });
                              return;
                            }

                            final memberName = name.text.trim();
                            final memberEmail = email.text.trim();
                            final memberPhone = phone.text.trim();
                            final paidText = paid.text.trim();
                            final paidAmount = double.tryParse(paidText);
                            if (paidAmount == null) return;

                            final p = ref.read(appProviderProvider);
                            try {
                              await AppLoader.run<void>(
                                context: context,
                                message: m == null
                                    ? 'Adding member...'
                                    : 'Updating member...',
                                task: () async {
                                  if (m == null) {
                                    await p.addMember(
                                      memberName,
                                      memberEmail,
                                      memberPhone,
                                      paidAmount,
                                      selectedImagePath,
                                    );
                                  } else {
                                    await p.updateMember(
                                      m,
                                      memberName,
                                      memberEmail,
                                      memberPhone,
                                      paidAmount,
                                      selectedImagePath,
                                    );
                                  }
                                },
                              );
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e
                                        .toString()
                                        .replaceFirst('Exception: ', ''),
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(appProviderProvider);
    final members = p.members;
    final totalPaid = members.fold<double>(
      0,
      (sum, member) => sum + member.paidAmount,
    );
    final totalDue = members.fold<double>(
      0,
      (sum, member) {
        final balance = p.memberBalance(member);
        return balance < 0 ? sum + balance.abs() : sum;
      },
    );

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  ),
                ),
                child: const Text(
                  'All Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: members.isEmpty
                    ? const Center(
                        child: Text(
                          'No members yet',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final member = members[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F8FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member.email,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member.phone,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _openDialer(context, member.phone),
                                  icon: const Icon(
                                    Icons.phone,
                                    color: Color(0xFF1565C0),
                                  ),
                                  tooltip: 'Call',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          if (p.isManager)
            IconButton(
              onPressed: () => openForm(context, ref),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: members.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFDCE8FF)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x401565C0),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No Members Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183153),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: members.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Members',
                            value: members.length.toString(),
                            icon: Icons.groups_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Paid',
                            value: 'Tk ${totalPaid.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Due',
                            value: 'Tk ${totalDue.toStringAsFixed(0)}',
                            icon: Icons.warning_amber_rounded,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final m = members[i - 1];
                final bal = p.memberBalance(m);
                final isAdvance = bal >= 0;
                final createdAtText = _formatDate(m.createdAt);
                final paymentDateText = m.lastPaymentAt == null
                    ? 'No payment yet'
                    : _formatDate(m.lastPaymentAt!);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2.2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F0FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: m.imagePath != null &&
                                      m.imagePath!.isNotEmpty &&
                                      !kIsWeb
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        File(m.imagePath!),
                                        height: 48,
                                        width: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          m.name.isNotEmpty
                                              ? m.name
                                                  .trim()
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : 'M',
                                          style: const TextStyle(
                                            color: Color(0xFF1565C0),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      m.name.isNotEmpty
                                          ? m.name
                                              .trim()
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : 'M',
                                      style: const TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    m.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _openDialer(context, m.phone),
                              icon: const Icon(
                                Icons.phone_outlined,
                                size: 18,
                              ),
                              tooltip: 'Call',
                            ),
                            if (p.isManager)
                              PopupMenuButton<String>(
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'pay',
                                    child: Text('Add Payment'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (v) async {
                                  if (v == 'edit') openForm(context, ref, m);
                                  if (v == 'delete') {
                                    final ok = await _confirmDelete(context);
                                    if (ok) {
                                      await AppLoader.run<void>(
                                        context: context,
                                        message: 'Deleting member...',
                                        task: () => p.deleteMember(m.id),
                                      );
                                    }
                                  }
                                  if (v == 'pay') {
                                    final c = TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Add Payment'),
                                        content: TextField(
                                          controller: c,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Amount',
                                          ),
                                        ),
                                        actions: [
                                          FilledButton(
                                            onPressed: () async {
                                              try {
                                                await AppLoader.run<void>(
                                                  context: context,
                                                  message: 'Adding payment...',
                                                  task: () => p.addPayment(
                                                    m,
                                                    double.tryParse(c.text) ??
                                                        0,
                                                  ),
                                                );
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.toString().replaceFirst(
                                                            'Exception: ',
                                                            '',
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              )
                            else
                              _BalancePill(isAdvance: isAdvance, amount: bal),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2ECFA)),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.phone_android_outlined,
                                text: m.phone,
                              ),
                              const SizedBox(height: 7),
                              _InfoRow(
                                icon: Icons.calendar_month_outlined,
                                text: 'Added: $createdAtText',
                              ),
                              const SizedBox(height: 7),
                              _InfoRow(
                                icon: Icons.history_toggle_off,
                                text: 'Last Payment: $paymentDateText',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PrimaryHistoryButton(
                          onTap: () => _showPaymentHistory(context, m),
                        ),
                        if (p.isManager) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child:
                                _BalancePill(isAdvance: isAdvance, amount: bal),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF5E6B7A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2F3B48),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFE9F2FF),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5FB),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final bool isAdvance;
  final double amount;

  const _BalancePill({
    required this.isAdvance,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isAdvance ? const Color(0xFFE5F7ED) : const Color(0xFFFFECEC);
    final textColor =
        isAdvance ? const Color(0xFF1D8B4F) : const Color(0xFFC23030);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '${isAdvance ? 'Advance' : 'Due'}  Tk ${amount.abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _PrimaryHistoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryHistoryButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'Payment History',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
