import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/meal.dart';
import '../models/member.dart';
import '../models/notice.dart';
import '../services/email_notice_service.dart';

final appProviderProvider = ChangeNotifierProvider<AppProvider>((ref) {
  throw UnimplementedError(
      'Must be overridden in main() after AppProvider.load()');
});

class AppProvider extends ChangeNotifier {
  List<Member> members = [];
  List<Expense> expenses = [];
  List<MealEntry> meals = [];
  List<NoticeItem> notices = [];

  String? currentPhone;
  String currentRole = 'manager';
  bool onboarded = false;
  String mockOtp = '1234';

  bool get isLoggedIn => currentPhone != null;
  bool get isManager => currentRole == 'manager';

  double get totalCost =>
      expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get totalMeals => meals.fold(0, (sum, meal) => sum + meal.total);
  double get mealRate => totalMeals == 0 ? 0 : totalCost / totalMeals;

  double memberMeals(String id) {
    return meals
        .where((meal) => meal.memberId == id)
        .fold(0, (sum, meal) => sum + meal.total);
  }

  double memberCost(String id) => memberMeals(id) * mealRate;
  double memberBalance(Member member) =>
      member.paidAmount - memberCost(member.id);

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

    members = (jsonDecode(sp.getString('members') ?? '[]') as List)
        .map((item) => Member.fromJson(item))
        .toList();
    expenses = (jsonDecode(sp.getString('expenses') ?? '[]') as List)
        .map((item) => Expense.fromJson(item))
        .toList();
    meals = (jsonDecode(sp.getString('meals') ?? '[]') as List)
        .map((item) => MealEntry.fromJson(item))
        .toList();
    notices = (jsonDecode(sp.getString('notices') ?? '[]') as List)
        .map((item) => NoticeItem.fromJson(item))
        .toList();

    if (members.isEmpty) {
      members.add(
        Member(
          id: 'm1',
          name: 'Manager',
          phone: 'lms.razinsoft@gmail.com',
          paidAmount: 5000,
        ),
      );
      members.add(
        Member(
          id: 'm2',
          name: 'Demo Member',
          phone: 'member@example.com',
          paidAmount: 1000,
        ),
      );
      expenses.add(
        Expense(
          id: 'e1',
          title: 'Rice, Oil, Egg',
          amount: 1800,
          paidByMemberId: 'm1',
          date: DateTime.now(),
          items: ['Rice', 'Oil', 'Egg'],
        ),
      );
      meals.add(
        MealEntry(
          id: 'me1',
          memberId: 'm1',
          date: DateTime.now(),
          breakfast: 1,
          lunch: 1,
          dinner: 1,
        ),
      );
      notices.add(
        NoticeItem(
          id: 'n1',
          title: 'Welcome to MessMate',
          text: 'Manager can now send notice and email notification.',
          date: DateTime.now(),
          sendToAll: true,
        ),
      );
      await save();
    }
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarded', onboarded);
    if (currentPhone != null) await sp.setString('currentPhone', currentPhone!);
    await sp.setString('currentRole', currentRole);
    await sp.setString(
        'members', jsonEncode(members.map((item) => item.toJson()).toList()));
    await sp.setString(
        'expenses', jsonEncode(expenses.map((item) => item.toJson()).toList()));
    await sp.setString(
        'meals', jsonEncode(meals.map((item) => item.toJson()).toList()));
    await sp.setString(
        'notices', jsonEncode(notices.map((item) => item.toJson()).toList()));
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await save();
    notifyListeners();
  }

  Future<void> login(String phone, String role) async {
    currentPhone = phone;
    currentRole = role;
    await save();
    notifyListeners();
  }

  Future<void> register(String name, String phone, String role) async {
    if (role == 'member' && members.every((member) => member.phone != phone)) {
      members.add(Member(id: _id(), name: name, phone: phone));
    }
    await login(phone, role);
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
    notifyListeners();
  }

  Future<void> addMember(String name, String phone, double paid) async {
    members.add(Member(id: _id(), name: name, phone: phone, paidAmount: paid));
    await save();
    notifyListeners();
  }

  Future<void> updateMember(
      Member member, String name, String phone, double paid) async {
    member.name = name;
    member.phone = phone;
    member.paidAmount = paid;
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
    member.paidAmount += amount;
    await save();
    notifyListeners();
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
    expenses.add(
      Expense(
        id: _id(),
        title: title,
        amount: amount,
        paidByMemberId: memberId,
        date: DateTime.now(),
        category: category,
        items: items,
      ),
    );
    await save();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense, String title, double amount,
      String category, List<String> items) async {
    expense.title = title;
    expense.amount = amount;
    expense.category = category;
    expense.items = items;
    await save();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((expense) => expense.id == id);
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
        .map((member) => member.phone.trim())
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
}
