import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyData {
  final String code;
  final String flag;
  final String name;
  final String symbol;

  const CurrencyData({
    required this.code,
    required this.flag,
    required this.name,
    required this.symbol,
  });
}

class CurrencyProvider with ChangeNotifier {
  static const String _storageKey = 'selected_currency';
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = ['USD', 'AED', 'EUR', 'GBP'];

  static const Map<String, CurrencyData> currencyMap = {
    'USD': CurrencyData(
      code: 'USD',
      flag: '🇺🇸',
      name: 'US Dollar',
      symbol: '\$',
    ),
    'AED': CurrencyData(
      code: 'AED',
      flag: '🇦🇪',
      name: 'UAE Dirham',
      symbol: 'د.إ',
    ),
    'EUR': CurrencyData(
      code: 'EUR',
      flag: '🇪🇺',
      name: 'Euro',
      symbol: '€',
    ),
    'GBP': CurrencyData(
      code: 'GBP',
      flag: '🇬🇧',
      name: 'British Pound',
      symbol: '£',
    ),
  };

  String _selectedCurrency = defaultCurrency;

  String get selectedCurrency => _selectedCurrency;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null && supportedCurrencies.contains(stored)) {
      _selectedCurrency = stored;
      notifyListeners();
    }
  }

  Future<void> setCurrency(String currency) async {
    if (!supportedCurrencies.contains(currency)) return;
    if (_selectedCurrency == currency) return;
    _selectedCurrency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, currency);
  }
}
