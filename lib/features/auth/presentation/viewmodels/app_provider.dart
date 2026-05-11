import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:messmate_app_full/core/constants/app_constants.dart';
import 'package:messmate_app_full/features/auth/data/services/auth_service.dart';
import 'package:messmate_app_full/features/auth/data/services/auth_token_service.dart';
import 'package:messmate_app_full/features/expenses/data/models/expense.dart';
import 'package:messmate_app_full/features/meals/data/models/meal.dart';
import 'package:messmate_app_full/features/members/data/models/member.dart';
import 'package:messmate_app_full/features/notices/data/models/notice.dart';
import 'package:messmate_app_full/features/notices/data/services/email_notice_service.dart';

final appProviderProvider = ChangeNotifierProvider<AppProvider>((ref) {
  throw UnimplementedError(
      'Must be overridden in main() after AppProvider.load()');
});

class MemberSettlement {
  final Member member;
  final double paid;
  final double share;
  final double netAmount;

  const MemberSettlement({
    required this.member,
    required this.paid,
    required this.share,
    required this.netAmount,
  });

  bool get willReceive => netAmount > 0;
  bool get willPay => netAmount < 0;
}

class AppProvider extends ChangeNotifier {
  static const String _membersKey = 'members';
  static const String _expensesKey = 'expenses';
  static const String _mealsKey = 'meals';
  static const String _noticesKey = 'notices';
  static const String _membersBackupKey = 'members_backup';
  static const String _expensesBackupKey = 'expenses_backup';
  static const String _mealsBackupKey = 'meals_backup';
  static const String _noticesBackupKey = 'notices_backup';
  static const String _languageCodeKey = 'language_code';
  static const String _gasBillKey = 'utility_gas_bill';
  static const String _currentBillKey = 'utility_current_bill';

  List<Member> members = [];
  List<Expense> expenses = [];
  List<MealEntry> meals = [];
  List<NoticeItem> notices = [];

  String? currentPhone;
  String currentRole = 'manager';
  bool onboarded = false;
  String languageCode = 'en';
  String mockOtp = '1234';
  double gasBill = 0;
  double currentBill = 0;

  bool get isLoggedIn => currentPhone != null;
  bool get isManager =>
      AppConstants.skipLoginForTesting || currentRole == 'manager';

  double get totalCost =>
      expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get totalMeals => meals.fold(0, (sum, meal) => sum + meal.total);
  double get mealRate => totalMeals == 0 ? 0 : totalCost / totalMeals;
  double get equalCostPerMember =>
      members.isEmpty ? 0 : totalCost / members.length;

  double memberMeals(String id) {
    return meals
        .where((meal) => meal.memberId == id)
        .fold(0, (sum, meal) => sum + meal.total);
  }

  double memberCost(String id) => equalCostPerMember;
  double memberBalance(Member member) =>
      member.paidAmount - memberCost(member.id);
  List<MemberSettlement> get memberSettlements => members
      .map(
        (member) => MemberSettlement(
          member: member,
          paid: member.paidAmount,
          share: memberCost(member.id),
          netAmount: memberBalance(member),
        ),
      )
      .toList();
  List<MemberSettlement> get receivableSettlements =>
      memberSettlements.where((settlement) => settlement.willReceive).toList()
        ..sort((a, b) => b.netAmount.compareTo(a.netAmount));
  List<MemberSettlement> get payableSettlements =>
      memberSettlements.where((settlement) => settlement.willPay).toList()
        ..sort((a, b) => a.netAmount.compareTo(b.netAmount));

  List<NoticeItem> visibleNoticesForCurrentUser() {
    if (isManager) return notices;

    final matches =
        members.where((member) => member.phone == currentPhone).toList();
    if (matches.isEmpty)
      return notices.where((notice) => notice.sendToAll).toList();

    final currentMember = matches.first;
    return notices.where((notice) {
      return notice.sendToAll ||
          notice.targetMemberIds.contains(currentMember.id);
    }).toList();
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    onboarded = sp.getBool('onboarded') ?? false;
    currentPhone = sp.getString('currentPhone');
    currentRole = sp.getString('currentRole') ?? 'manager';
    languageCode = sp.getString(_languageCodeKey) ?? 'en';
    gasBill = sp.getDouble(_gasBillKey) ?? 0;
    currentBill = sp.getDouble(_currentBillKey) ?? 0;

    members = _decodeListWithBackup(
      primary: sp.getString(_membersKey),
      backup: sp.getString(_membersBackupKey),
      mapper: Member.fromJson,
    );
    expenses = _decodeListWithBackup(
      primary: sp.getString(_expensesKey),
      backup: sp.getString(_expensesBackupKey),
      mapper: Expense.fromJson,
    );
    meals = _decodeListWithBackup(
      primary: sp.getString(_mealsKey),
      backup: sp.getString(_mealsBackupKey),
      mapper: MealEntry.fromJson,
    );
    notices = _decodeListWithBackup(
      primary: sp.getString(_noticesKey),
      backup: sp.getString(_noticesBackupKey),
      mapper: NoticeItem.fromJson,
    );
    if (AppConstants.skipLoginForTesting && notices.isEmpty) {
      notices = <NoticeItem>[
        NoticeItem(
          id: _id(),
          title: 'Monthly Meal Charge Update',
          text:
              'Meal rate has been updated to 92 BDT from next week. Please clear dues by Friday.',
          date: DateTime.now().subtract(const Duration(hours: 4)),
          sender: 'Manager',
        ),
        NoticeItem(
          id: _id(),
          title: 'Water Supply Maintenance',
          text:
              'Water supply may remain off from 10:00 AM to 1:00 PM tomorrow due to maintenance work.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          sender: 'Admin',
        ),
        NoticeItem(
          id: _id(),
          title: 'General Meeting Reminder',
          text:
              'All members are requested to join the monthly meeting tonight at 9:30 PM in the dining area.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          sender: 'Manager',
        ),
      ];
      await save();
    }

    final accessToken = await AuthTokenService.getAccessToken();
    if ((accessToken == null || accessToken.isEmpty) && currentPhone != null) {
      // Keep local state consistent with auth state.
      currentPhone = null;
    }
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarded', onboarded);
    if (currentPhone != null) await sp.setString('currentPhone', currentPhone!);
    await sp.setString('currentRole', currentRole);
    await sp.setString(_languageCodeKey, languageCode);
    await sp.setDouble(_gasBillKey, gasBill);
    await sp.setDouble(_currentBillKey, currentBill);
    final membersJson =
        jsonEncode(members.map((item) => item.toJson()).toList());
    final expensesJson =
        jsonEncode(expenses.map((item) => item.toJson()).toList());
    final mealsJson = jsonEncode(meals.map((item) => item.toJson()).toList());
    final noticesJson =
        jsonEncode(notices.map((item) => item.toJson()).toList());

    await sp.setString(_membersKey, membersJson);
    await sp.setString(_expensesKey, expensesJson);
    await sp.setString(_mealsKey, mealsJson);
    await sp.setString(_noticesKey, noticesJson);

    // Secondary backup snapshot to reduce accidental data loss risk.
    await sp.setString(_membersBackupKey, membersJson);
    await sp.setString(_expensesBackupKey, expensesJson);
    await sp.setString(_mealsBackupKey, mealsJson);
    await sp.setString(_noticesBackupKey, noticesJson);
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await save();
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    final normalized = code.toLowerCase();
    if (normalized != 'bn' && normalized != 'en') return;
    if (languageCode == normalized) return;
    languageCode = normalized;
    await save();
    notifyListeners();
  }

  Future<void> login(String email, String password, String role) async {
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedEmail.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }
    final result = await AuthService.login(
      email: cleanedEmail,
      password: password,
      role: role,
    );
    await AuthTokenService.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );

    currentPhone = result.identifier;
    currentRole = result.role;
    await save();
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || password.isEmpty) {
      throw Exception('Name, email and password are required.');
    }
    final result = await AuthService.register(
      name: cleanedName,
      email: cleanedEmail,
      password: password,
      passwordConfirmation: password,
      role: role,
    );
    await AuthTokenService.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );

    // Keep local member list synced for UI summary.
    if (role == 'member' &&
        members.every((member) => member.phone != cleanedEmail)) {
      members.add(
        Member(
          id: _id(),
          name: cleanedName,
          email: cleanedEmail,
          phone: cleanedEmail,
          createdAt: DateTime.now(),
        ),
      );
    }
    currentPhone = cleanedEmail;
    currentRole = role;
    await save();
    notifyListeners();
  }

  String sendOtp(String phone) {
    mockOtp = '1234';
    return mockOtp;
  }

  Future<bool> verifyOtp(String otp) async => otp == mockOtp;

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    currentPhone = null;
    await sp.remove('currentPhone');
    await AuthTokenService.clearTokens();
    notifyListeners();
  }

  Future<bool> handleUnauthorized() async {
    await logout();
    return false;
  }

  Future<void> addMember(
    String name,
    String email,
    String phone,
    double paid,
    String? imagePath,
  ) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    final cleanedPhone = phone.trim();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || cleanedPhone.isEmpty) {
      throw Exception('Member name, email and phone are required.');
    }
    if (!cleanedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    if (members.any((member) => member.phone == cleanedPhone)) {
      throw Exception('A member with this phone already exists.');
    }
    if (members.any((member) => member.email == cleanedEmail)) {
      throw Exception('A member with this email already exists.');
    }
    members.add(
      Member(
        id: _id(),
        name: cleanedName,
        email: cleanedEmail,
        phone: cleanedPhone,
        imagePath: imagePath?.trim().isEmpty == true ? null : imagePath,
        paidAmount: paid < 0 ? 0 : paid,
        createdAt: DateTime.now(),
        lastPaymentAt: paid > 0 ? DateTime.now() : null,
        paymentHistory: paid > 0
            ? [
                MemberPayment(
                  amount: paid,
                  paidAt: DateTime.now(),
                ),
              ]
            : [],
      ),
    );
    await save();
    notifyListeners();
  }

  Future<void> updateMember(
    Member member,
    String name,
    String email,
    String phone,
    double paid,
    String? imagePath,
  ) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    final cleanedPhone = phone.trim();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || cleanedPhone.isEmpty) {
      throw Exception('Member name, email and phone are required.');
    }
    if (!cleanedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    final duplicatePhone = members.any(
      (m) => m.id != member.id && m.phone == cleanedPhone,
    );
    final duplicateEmail = members.any(
      (m) => m.id != member.id && m.email == cleanedEmail,
    );
    if (duplicatePhone) {
      throw Exception('Another member already uses this phone.');
    }
    if (duplicateEmail) {
      throw Exception('Another member already uses this email.');
    }
    member.name = cleanedName;
    member.email = cleanedEmail;
    member.phone = cleanedPhone;
    member.imagePath = imagePath?.trim().isEmpty == true ? null : imagePath;
    final sanitizedPaid = paid < 0 ? 0.0 : paid;
    if (sanitizedPaid != member.paidAmount) {
      member.lastPaymentAt = sanitizedPaid > 0 ? DateTime.now() : null;
      _syncPaymentHistoryWithTotal(member, sanitizedPaid);
    }
    member.paidAmount = sanitizedPaid;
    await save();
    notifyListeners();
  }

  Future<void> deleteMember(String id) async {
    members.removeWhere((member) => member.id == id);
    meals.removeWhere((meal) => meal.memberId == id);
    for (final notice in notices) {
      notice.targetMemberIds.remove(id);
    }
    await save();
    notifyListeners();
  }

  Future<void> addPayment(Member member, double amount) async {
    if (amount <= 0) {
      throw Exception('Payment amount must be greater than 0.');
    }
    member.paidAmount += amount;
    final now = DateTime.now();
    member.lastPaymentAt = now;
    member.paymentHistory.add(
      MemberPayment(
        amount: amount,
        paidAt: now,
      ),
    );
    await save();
    notifyListeners();
  }

  void _syncPaymentHistoryWithTotal(Member member, double totalPaid) {
    final now = DateTime.now();
    if (totalPaid <= 0) {
      member.paymentHistory = [];
      return;
    }

    final historySum = member.paymentHistory.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final delta = totalPaid - historySum;

    if (delta > 0) {
      member.paymentHistory.add(
        MemberPayment(
          amount: delta,
          paidAt: now,
        ),
      );
      return;
    }

    if (delta < 0) {
      // If total is reduced manually, rebuild history to keep total consistent.
      member.paymentHistory = [
        MemberPayment(
          amount: totalPaid,
          paidAt: now,
        ),
      ];
    }
  }

  Future<void> addMeal(
      String memberId, double breakfast, double lunch, double dinner) async {
    meals.add(
      MealEntry(
        id: _id(),
        memberId: memberId,
        date: DateTime.now(),
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      ),
    );
    await save();
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    meals.removeWhere((meal) => meal.id == id);
    await save();
    notifyListeners();
  }

  Future<void> addExpense(String title, double amount, String memberId,
      String category, List<String> items) async {
    if (members.isEmpty) {
      throw Exception(
          'No member found. Add at least one member before adding bazar/cost.');
    }
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw Exception('Expense title is required.');
    }
    if (amount <= 0) {
      throw Exception('Expense amount must be greater than 0.');
    }
    expenses.add(
      Expense(
        id: _id(),
        title: cleanTitle,
        amount: amount,
        // Stored for "who did the bazar/cost" display; settlement is still shared equally.
        paidByMemberId: memberId,
        date: DateTime.now(),
        category: category,
        items: items.where((item) => item.trim().isNotEmpty).toList(),
      ),
    );
    await save();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense, String title, double amount,
      String category, List<String> items) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw Exception('Expense title is required.');
    }
    if (amount <= 0) {
      throw Exception('Expense amount must be greater than 0.');
    }
    expense.title = cleanTitle;
    expense.amount = amount;
    expense.category = category;
    expense.items = items.where((item) => item.trim().isNotEmpty).toList();
    await save();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((expense) => expense.id == id);
    await save();
    notifyListeners();
  }

  Future<void> setUtilityBills({
    required double gas,
    required double current,
  }) async {
    gasBill = gas < 0 ? 0 : gas;
    currentBill = current < 0 ? 0 : current;
    await save();
    notifyListeners();
  }

  Future<bool> addNotice({
    required String title,
    required String text,
    required bool sendToAll,
    required List<String> targetMemberIds,
    bool sendEmail = true,
  }) async {
    final notice = NoticeItem(
      id: _id(),
      title: title,
      text: text,
      date: DateTime.now(),
      sender: 'Manager',
      sendToAll: sendToAll,
      targetMemberIds: sendToAll ? [] : targetMemberIds,
    );

    notices.add(notice);
    await save();
    notifyListeners();

    if (!sendEmail) return false;

    final selectedMembers = sendToAll
        ? members
        : members
            .where((member) => targetMemberIds.contains(member.id))
            .toList();

    final emails = selectedMembers
        .map((member) => member.email.trim())
        .where((contact) => contact.contains('@'))
        .toSet()
        .toList();

    return EmailNoticeService.sendNoticeEmail(
      emails: emails,
      title: title,
      message: text,
    );
  }

  Future<void> updateNotice({
    required NoticeItem notice,
    required String title,
    required String text,
    required bool sendToAll,
    required List<String> targetMemberIds,
  }) async {
    notice.title = title;
    notice.text = text;
    notice.sendToAll = sendToAll;
    notice.targetMemberIds = sendToAll ? [] : targetMemberIds;
    await save();
    notifyListeners();
  }

  Future<void> deleteNotice(String id) async {
    notices.removeWhere((notice) => notice.id == id);
    await save();
    notifyListeners();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  List<T> _decodeList<T>(
      String? source, T Function(Map<String, dynamic>) mapper) {
    if (source == null || source.isEmpty) return [];
    try {
      final decoded = jsonDecode(source) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList(growable: true);
    } catch (_) {
      return [];
    }
  }

  List<T> _decodeListWithBackup<T>({
    required String? primary,
    required String? backup,
    required T Function(Map<String, dynamic>) mapper,
  }) {
    final primaryList = _decodeList(primary, mapper);
    if (primaryList.isNotEmpty || (primary != null && primary.trim() == '[]')) {
      return primaryList;
    }
    return _decodeList(backup, mapper);
  }
}
