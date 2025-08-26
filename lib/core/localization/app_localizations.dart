import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
  ];

  // Helper method to get localized string
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // App Strings
  String get appName => translate('app_name');
  String get login => translate('login');
  String get signUp => translate('sign_up');
  String get email => translate('email');
  String get password => translate('password');
  String get organizations => translate('organizations');
  String get chalans => translate('chalans');
  String get addChalan => translate('add_chalan');
  String get chalanNumber => translate('chalan_number');
  String get description => translate('description');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get ascending => translate('ascending');
  String get descending => translate('descending');
  String get filters => translate('filters');
  String get clearAll => translate('clear_all');
  String get dateRange => translate('date_range');
  String get monthFilter => translate('month_filter');
  String get chalanNumberRange => translate('chalan_number_range');
  String get createdBy => translate('created_by');
  String get sortOptions => translate('sort_options');
  String get sortBy => translate('sort_by');
  String get sortOrder => translate('sort_order');
  String get applyFilters => translate('apply_filters');
  String get fromDate => translate('from_date');
  String get toDate => translate('to_date');
  String get fromNumber => translate('from_number');
  String get toNumber => translate('to_number');
  String get year => translate('year');
  String get searchChalans => translate('search_chalans');
  String get loadingChalans => translate('loading_chalans');
  String get noOrganizationSelected => translate('no_organization_selected');
  String get selectOrCreateOrganization =>
      translate('select_or_create_organization');
  String get goToOrganizations => translate('go_to_organizations');
  String get goToOrganizationsTab => translate('go_to_organizations_tab');
  String get noChalansFound => translate('no_chalans_found');
  String get addFirstChalan => translate('add_first_chalan');
  String get noResultsFound => translate('no_results_found');
  String get adjustFilters => translate('adjust_filters');
  String get clearFilters => translate('clear_filters');
  String get somethingWentWrong => translate('something_went_wrong');
  String get tryAgain => translate('try_again');
  String get view => translate('view');
  String get unknown => translate('unknown');
  String get me => translate('me');
  String get member => translate('member');
  String get deleteChalanConfirmation =>
      translate('delete_chalan_confirmation');
  String get actionCannotBeUndone => translate('action_cannot_be_undone');
  String get createdDate => translate('created_date');
  String get date => translate('date');

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Chalan Book',
      'login': 'Login',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'organizations': 'Organizations',
      'chalans': 'Chalans',
      'add_chalan': 'Add Chalan',
      'chalan_number': 'Chalan Number',
      'description': 'Description',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'ascending': 'Ascending',
      'descending': 'Descending',
      'filters': 'Filters',
      'clear_all': 'Clear All',
      'date_range': 'Date Range',
      'month_filter': 'Month Filter',
      'chalan_number_range': 'Chalan Number Range',
      'created_by': 'Created By',
      'sort_options': 'Sort Options',
      'sort_by': 'Sort By',
      'sort_order': 'Sort Order',
      'apply_filters': 'Apply Filters',
      'from_date': 'From Date',
      'to_date': 'To Date',
      'from_number': 'From Number',
      'to_number': 'To Number',
      'year': 'Year',
      'search_chalans': 'Search chalans...',
      'loading_chalans': 'Loading your chalans...',
      'no_organization_selected': 'No Organization Selected',
      'select_or_create_organization':
          'Please select or create an organization first',
      'go_to_organizations': 'Go to Organizations',
      'go_to_organizations_tab': 'Go to the Organizations tab',
      'no_chalans_found': 'No Chalans Found',
      'add_first_chalan': 'Add your first chalan to get started',
      'no_results_found': 'No Results Found',
      'adjust_filters': 'Try adjusting your filters or search terms',
      'clear_filters': 'Clear Filters',
      'something_went_wrong': 'Oops! Something went wrong',
      'try_again': 'Try Again',
      'view': 'View',
      'unknown': 'Unknown',
      'me': 'Me',
      'member': 'Member',
      'delete_chalan_confirmation':
          'Are you sure you want to delete this chalan?',
      'action_cannot_be_undone': 'This action cannot be undone.',
      'created_date': 'Created Date',
      'date': 'Date',
    },
    'hi': {
      'app_name': 'चालान बुक',
      'login': 'लॉगिन',
      'sign_up': 'साइन अप',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'organizations': 'संगठन',
      'chalans': 'चालान',
      'add_chalan': 'चालान जोड़ें',
      'chalan_number': 'चालान नंबर',
      'description': 'विवरण',
      'save': 'सेव',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'search': 'खोजें',
      'filter': 'फिल्टर',
      'sort': 'क्रमबद्ध करें',
      'ascending': 'आरोही',
      'descending': 'अवरोही',
      'filters': 'फिल्टर',
      'clear_all': 'सभी साफ़ करें',
      'date_range': 'दिनांक सीमा',
      'month_filter': 'महीना फिल्टर',
      'chalan_number_range': 'चालान नंबर सीमा',
      'created_by': 'द्वा��ा बनाया गया',
      'sort_options': 'सॉर्ट विकल्प',
      'sort_by': 'इसके द्वारा सॉर्ट करें',
      'sort_order': 'सॉर्ट क्रम',
      'apply_filters': 'फिल्टर लागू करें',
      'from_date': 'से दिनांक',
      'to_date': 'तक दिनांक',
      'from_number': 'से नंबर',
      'to_number': 'तक नंबर',
      'year': 'वर्ष',
      'search_chalans': 'चालान खोजें...',
      'loading_chalans': 'आपके चालान लोड हो रहे हैं...',
      'no_organization_selected': 'कोई संगठन चयनित नहीं',
      'select_or_create_organization': 'कृपया पहले एक संगठन चुनें या बनाएं',
      'go_to_organizations': 'संगठनों पर जाएं',
      'go_to_organizations_tab': 'संगठन टैब पर जाएं',
      'no_chalans_found': 'कोई चालान नहीं मिला',
      'add_first_chalan': 'शुरुआत करने के लिए अपना पहला चालान जोड़ें',
      'no_results_found': 'कोई परिणाम नहीं मिला',
      'adjust_filters':
          'अपने फिल्टर या खोज शब्दों को समायोजित करने का प्रयास करें',
      'clear_filters': 'फिल्टर साफ़ करें',
      'something_went_wrong': 'ओह! कुछ गलत हुआ',
      'try_again': 'पुनः प्रयास करें',
      'view': 'देखें',
      'unknown': 'अज्ञात',
      'me': 'मैं',
      'member': 'सदस्य',
      'delete_chalan_confirmation': 'क्या आप वाकई इस चालान को हटाना चाहते हैं?',
      'action_cannot_be_undone': 'यह क्रिया पूर्ववत नहीं की जा सकती।',
      'created_date': 'बनाने की तारीख',
      'date': 'दिनांक',
    },
    'gu': {
      'app_name': 'ચાલાન બુક',
      'login': 'લૉગિન',
      'sign_up': 'સાઇન અપ',
      'email': 'ઇમેઇલ',
      'password': 'પાસવર્ડ',
      'organizations': 'સંસ્થાઓ',
      'chalans': 'ચાલાન',
      'add_chalan': 'ચાલાન ઉમેરો',
      'chalan_number': 'ચાલાન નંબર',
      'description': 'વર્ણન',
      'save': 'સેવ કરો',
      'cancel': 'રદ કરો',
      'delete': 'મિટાવો',
      'edit': 'સંપાદિત કરો',
      'search': 'શોધો',
      'filter': 'ફિલ્ટર',
      'sort': 'ક્રમબદ્ધ કરો',
      'ascending': 'ઉત્ક્રમમાં',
      'descending': 'અવત્ક્રમમાં',
      'filters': 'ફિલ્ટર્સ',
      'clear_all': 'બધા સાફ કરો',
      'date_range': 'તારીખ શ્રેણી',
      'month_filter': 'મહિનો ફિલ્ટર',
      'chalan_number_range': 'ચાલાન નંબર શ્રેણી',
      'created_by': 'દ્વારા બનાવેલ',
      'sort_options': 'ક્રમબદ્ધ વિકલ્પો',
      'sort_by': 'આધારે ક્રમબદ્ધ કરો',
      'sort_order': 'ક્રમબદ્ધ ક્રમ',
      'apply_filters': 'ફિલ્ટર્સ લાગુ કરો',
      'from_date': 'તારીખથી શરૂ થાય છે',
      'to_date': 'તારીખ સુધી પહોંચે છે',
      // Add more translations as needed
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}
