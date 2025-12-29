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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get language;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current: English'**
  String get currentLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @myHome.
  ///
  /// In en, this message translates to:
  /// **'My Home'**
  String get myHome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @residents.
  ///
  /// In en, this message translates to:
  /// **'Residents'**
  String get residents;

  /// No description provided for @noResidentsFound.
  ///
  /// In en, this message translates to:
  /// **'No active residents found.'**
  String get noResidentsFound;

  /// No description provided for @myProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get myProperties;

  /// No description provided for @addProperty.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get addProperty;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'No properties yet.'**
  String get noPropertiesYet;

  /// No description provided for @addFirstProperty.
  ///
  /// In en, this message translates to:
  /// **'Add your first property'**
  String get addFirstProperty;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get statusActive;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'NOT ASSIGNED'**
  String get statusNotAssigned;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @welcomeResident.
  ///
  /// In en, this message translates to:
  /// **'Welcome Resident'**
  String get welcomeResident;

  /// No description provided for @outstandingDues.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Dues'**
  String get outstandingDues;

  /// No description provided for @payDue.
  ///
  /// In en, this message translates to:
  /// **'Pay Due'**
  String get payDue;

  /// No description provided for @payAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pay Advance'**
  String get payAdvance;

  /// No description provided for @noInvoiceYet.
  ///
  /// In en, this message translates to:
  /// **'No Invoice Yet'**
  String get noInvoiceYet;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @contactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get contactOwner;

  /// No description provided for @requestInvoice.
  ///
  /// In en, this message translates to:
  /// **'Request Invoice'**
  String get requestInvoice;

  /// No description provided for @notAssignedDetail.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to a flat yet.'**
  String get notAssignedDetail;

  /// No description provided for @contactOwnerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please contact the property owner to get assigned.'**
  String get contactOwnerPrompt;

  /// No description provided for @noInvoiceDetail.
  ///
  /// In en, this message translates to:
  /// **'No invoice generated for this month.'**
  String get noInvoiceDetail;

  /// No description provided for @billSummary.
  ///
  /// In en, this message translates to:
  /// **'Bill Summary'**
  String get billSummary;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities & Charges'**
  String get utilities;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @apartmentInfo.
  ///
  /// In en, this message translates to:
  /// **'My Apartment Info'**
  String get apartmentInfo;

  /// No description provided for @baseRent.
  ///
  /// In en, this message translates to:
  /// **'Base Rent'**
  String get baseRent;

  /// No description provided for @totalLiability.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Liability'**
  String get totalLiability;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @rentDueReminder.
  ///
  /// In en, this message translates to:
  /// **'Rent is due on 5th of every month'**
  String get rentDueReminder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @invoiceRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Invoice Request Sent!'**
  String get invoiceRequestSent;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @completeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Complete Documents'**
  String get completeDocuments;

  /// No description provided for @noDuesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no outstanding dues. Great job!'**
  String get noDuesMessage;

  /// No description provided for @viewUnpaidBills.
  ///
  /// In en, this message translates to:
  /// **'View Unpaid Bills'**
  String get viewUnpaidBills;

  /// No description provided for @recentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Resident Requests'**
  String get recentRequests;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @assignedResident.
  ///
  /// In en, this message translates to:
  /// **'Assigned Resident'**
  String get assignedResident;

  /// No description provided for @leaseToFlat.
  ///
  /// In en, this message translates to:
  /// **'Lease to Flat'**
  String get leaseToFlat;

  /// No description provided for @residentUnknown.
  ///
  /// In en, this message translates to:
  /// **'Resident: Unknown'**
  String get residentUnknown;

  /// No description provided for @residentDetails.
  ///
  /// In en, this message translates to:
  /// **'Resident Details'**
  String get residentDetails;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @docsVerification.
  ///
  /// In en, this message translates to:
  /// **'Documents & Verification'**
  String get docsVerification;

  /// No description provided for @noDocsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No verification documents uploaded.'**
  String get noDocsUploaded;

  /// No description provided for @noDocsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No document images available.'**
  String get noDocsAvailable;

  /// No description provided for @nidFront.
  ///
  /// In en, this message translates to:
  /// **'NID Front'**
  String get nidFront;

  /// No description provided for @birthCertificate.
  ///
  /// In en, this message translates to:
  /// **'Birth Certificate'**
  String get birthCertificate;

  /// No description provided for @passportPhoto.
  ///
  /// In en, this message translates to:
  /// **'Passport Photo'**
  String get passportPhoto;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @activeResidentMessage.
  ///
  /// In en, this message translates to:
  /// **'You are an active resident. You can view your bills and history.'**
  String get activeResidentMessage;
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
    'that was used.',
  );
}
