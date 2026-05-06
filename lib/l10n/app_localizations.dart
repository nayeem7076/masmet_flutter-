import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MessMate'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @bazar.
  ///
  /// In en, this message translates to:
  /// **'Bazar'**
  String get bazar;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get searchProduct;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @loginType.
  ///
  /// In en, this message translates to:
  /// **'Login as'**
  String get loginType;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account Role'**
  String get accountRole;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @welcomeToMessMate.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MessMate'**
  String get welcomeToMessMate;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to manage your mess easily'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountBtn;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @joinMessMate.
  ///
  /// In en, this message translates to:
  /// **'Join MessMate'**
  String get joinMessMate;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to manage mess easily'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @enterNameEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter name, email and password'**
  String get enterNameEmailPassword;

  /// No description provided for @managerAccessNote.
  ///
  /// In en, this message translates to:
  /// **'Manager can add, edit and delete mess data.'**
  String get managerAccessNote;

  /// No description provided for @memberAccessNote.
  ///
  /// In en, this message translates to:
  /// **'Member can view meals, cost and balance.'**
  String get memberAccessNote;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterPhoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone or email'**
  String get enterPhoneOrEmail;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSent;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get enterOtp;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'OTP verified. You can login now.'**
  String get otpVerified;

  /// No description provided for @wrongOtp.
  ///
  /// In en, this message translates to:
  /// **'Wrong OTP'**
  String get wrongOtp;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your mess easily'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Member, bazar list, meal count, advance payment, due calculation and monthly report in one app.'**
  String get onboardingSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Mess Management'**
  String get splashTagline;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardHeader.
  ///
  /// In en, this message translates to:
  /// **'MessMate Dashboard'**
  String get dashboardHeader;

  /// No description provided for @dashboardSubheader.
  ///
  /// In en, this message translates to:
  /// **'Smart control of members, cost and balance'**
  String get dashboardSubheader;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @financialInsights.
  ///
  /// In en, this message translates to:
  /// **'Financial Insights'**
  String get financialInsights;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @perMemberCost.
  ///
  /// In en, this message translates to:
  /// **'Per Member Cost'**
  String get perMemberCost;

  /// No description provided for @totalAdvance.
  ///
  /// In en, this message translates to:
  /// **'Total Advance'**
  String get totalAdvance;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @allMembers.
  ///
  /// In en, this message translates to:
  /// **'All Members'**
  String get allMembers;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @addFirstMember.
  ///
  /// In en, this message translates to:
  /// **'No members yet.\\nTap + to add your first member.'**
  String get addFirstMember;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @advancePaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance/Paid Amount'**
  String get advancePaidAmount;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @deleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this member?'**
  String get deleteMemberConfirm;

  /// No description provided for @addingMember.
  ///
  /// In en, this message translates to:
  /// **'Adding member...'**
  String get addingMember;

  /// No description provided for @updatingMember.
  ///
  /// In en, this message translates to:
  /// **'Updating member...'**
  String get updatingMember;

  /// No description provided for @deletingMember.
  ///
  /// In en, this message translates to:
  /// **'Deleting member...'**
  String get deletingMember;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @addingPayment.
  ///
  /// In en, this message translates to:
  /// **'Adding payment...'**
  String get addingPayment;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @noPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'No payment history yet.'**
  String get noPaymentHistory;

  /// No description provided for @lastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last Payment'**
  String get lastPayment;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense title'**
  String get expenseTitle;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseItems.
  ///
  /// In en, this message translates to:
  /// **'Items (comma separated)'**
  String get expenseItems;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseOverview.
  ///
  /// In en, this message translates to:
  /// **'Expense Overview'**
  String get expenseOverview;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirm;

  /// No description provided for @addingExpense.
  ///
  /// In en, this message translates to:
  /// **'Adding expense...'**
  String get addingExpense;

  /// No description provided for @updatingExpense.
  ///
  /// In en, this message translates to:
  /// **'Updating expense...'**
  String get updatingExpense;

  /// No description provided for @deletingExpense.
  ///
  /// In en, this message translates to:
  /// **'Deleting expense...'**
  String get deletingExpense;

  /// No description provided for @noExpenseYet.
  ///
  /// In en, this message translates to:
  /// **'No Expenses Added Yet'**
  String get noExpenseYet;

  /// No description provided for @tapToAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first bazar or cost entry.'**
  String get tapToAddExpense;

  /// No description provided for @memberRequiredForExpense.
  ///
  /// In en, this message translates to:
  /// **'No member found. Add at least one member before adding bazar/cost.'**
  String get memberRequiredForExpense;

  /// No description provided for @expenseBy.
  ///
  /// In en, this message translates to:
  /// **'Bazar / Cost done by'**
  String get expenseBy;

  /// No description provided for @mealEntry.
  ///
  /// In en, this message translates to:
  /// **'Meal Entry'**
  String get mealEntry;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Report Summary'**
  String get reportSummary;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get totalMembers;

  /// No description provided for @perMemberShare.
  ///
  /// In en, this message translates to:
  /// **'Per Member Share'**
  String get perMemberShare;

  /// No description provided for @totalReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable'**
  String get totalReceivable;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @membersWillReceive.
  ///
  /// In en, this message translates to:
  /// **'Members Who Will Receive'**
  String get membersWillReceive;

  /// No description provided for @membersNeedToPay.
  ///
  /// In en, this message translates to:
  /// **'Members Who Need To Pay'**
  String get membersNeedToPay;

  /// No description provided for @settlementLogic.
  ///
  /// In en, this message translates to:
  /// **'Settlement Logic'**
  String get settlementLogic;

  /// No description provided for @settlementLogicText.
  ///
  /// In en, this message translates to:
  /// **'At the end of the month, total expenses are divided equally among all members. If someone paid more than their share, they will receive money. If someone paid less than their share, they need to pay the remaining amount.'**
  String get settlementLogicText;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @printExport.
  ///
  /// In en, this message translates to:
  /// **'Print / Export'**
  String get printExport;

  /// No description provided for @preparingReport.
  ///
  /// In en, this message translates to:
  /// **'Preparing report...'**
  String get preparingReport;

  /// No description provided for @exportingReport.
  ///
  /// In en, this message translates to:
  /// **'Exporting report...'**
  String get exportingReport;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @noticeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading notice...'**
  String get noticeLoading;

  /// No description provided for @noticeRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing notices...'**
  String get noticeRefreshing;

  /// No description provided for @noNoticeFound.
  ///
  /// In en, this message translates to:
  /// **'No notice found'**
  String get noNoticeFound;

  /// No description provided for @noDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No details found.'**
  String get noDetailsFound;

  /// No description provided for @phoneDialerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open phone dialer.'**
  String get phoneDialerFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
