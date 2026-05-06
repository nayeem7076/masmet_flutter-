import 'package:flutter/material.dart';

class AppText {
  AppText._();

  static const String deliverTo = 'deliverTo';
  static const String location = 'location';
  static const String searchProduct = 'searchProduct';
  static const String home = 'home';
  static const String members = 'members';
  static const String bazar = 'bazar';
  static const String report = 'report';
  static const String notice = 'notice';
  static const String language = 'language';
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String pleaseWait = 'pleaseWait';

  static const Map<String, String> _en = {
    deliverTo: 'Deliver to',
    location: 'Location',
    searchProduct: 'Search product',
    home: 'Home',
    members: 'Members',
    bazar: 'Bazar',
    report: 'Report',
    notice: 'Notice',
    language: 'Language',
    login: 'Login',
    register: 'Register',
    logout: 'Logout',
    pleaseWait: 'Please wait...',
  };

  static const Map<String, String> _bn = {
    deliverTo: 'ডেলিভারি ঠিকানা',
    location: 'লোকেশন',
    searchProduct: 'পণ্য খুঁজুন',
    home: 'হোম',
    members: 'মেম্বার',
    bazar: 'বাজার',
    report: 'রিপোর্ট',
    notice: 'নোটিশ',
    language: 'ভাষা',
    login: 'লগইন',
    register: 'রেজিস্টার',
    logout: 'লগআউট',
    pleaseWait: 'অপেক্ষা করুন...',
  };

  static bool _isBn(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'bn';

  static String tr(
    BuildContext context,
    String key, {
    String? enFallback,
    String? bnFallback,
  }) {
    final isBn = _isBn(context);
    final fromMap = isBn ? _bn[key] : _en[key];
    if (fromMap != null) return fromMap;
    if (isBn && bnFallback != null) return bnFallback;
    if (!isBn && enFallback != null) return enFallback;
    return key;
  }

  static String t(BuildContext context,
      {required String bn, required String en}) {
    return _isBn(context) ? bn : en;
  }
}
