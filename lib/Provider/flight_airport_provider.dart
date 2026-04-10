import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/modals/flight_airport_model.dart';

class FlightAirportProvider with ChangeNotifier {
  List<FlightAirportModel> _airports = [];
  List<FlightAirportModel> _filteredAirports = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  /// True when current results came from fuzzy fallback.
  bool _isFuzzyResult = false;

  /// Top fuzzy suggestion text for "Did you mean ...?" banner.
  String? _fuzzyDidYouMean;

  List<FlightAirportModel> get airports => _airports;
  List<FlightAirportModel> get filteredAirports => _filteredAirports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isFuzzyResult => _isFuzzyResult;
  String? get fuzzyDidYouMean => _fuzzyDidYouMean;

  Future<void> fetchAirports() async {
    if (_airports.isNotEmpty) {
      log('[FlightAirportProvider] Airports already cached — skipping fetch');
      return;
    }

    log('[FlightAirportAPI] Fetch started');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiUrls.baseUrl}${ApiUrls.flightAirports}';
      log('[FlightAirportAPI] URL: $url');

      final result = await makeRequest(url, 'GET', {}, '');

      if (result['success'] == true) {
        final response = FlightAirportResponseModel.fromJson(
            result['data'] as Map<String, dynamic>);
        _airports = response.data;
        _filteredAirports = List.from(_airports);
        log('[FlightAirportAPI] Success: ${_airports.length} airports fetched');
      } else {
        _error = result['message']?.toString() ?? 'Failed to load airports';
        log('[FlightAirportAPI] Error: $_error');
      }
    } catch (e) {
      _error = 'An error occurred while loading airports';
      log('[FlightAirportAPI] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterAirports(String query) {
    _searchQuery = query;
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    log('[FlightAirportProvider] Search query = $query');

    if (query.isEmpty) {
      _filteredAirports = List.from(_airports);
    } else {
      final q = query.toLowerCase();
      _filteredAirports = _airports.where((a) {
        return a.city.toLowerCase().contains(q) ||
            a.airport.toLowerCase().contains(q) ||
            a.iataCode.toLowerCase().contains(q) ||
            a.country.toLowerCase().contains(q);
      }).toList();

      // ── Fuzzy fallback when exact match returns empty ──────────────
      if (_filteredAirports.isEmpty && q.length >= 2) {
        log('[FlightAirportProvider] Exact match empty → trying fuzzy for "$q"');
        final scored = <_ScoredAirport>[];

        for (final a in _airports) {
          double best = 0;
          for (final field in [
            a.city.toLowerCase(),
            a.airport.toLowerCase(),
            a.iataCode.toLowerCase(),
            a.country.toLowerCase(),
          ]) {
            if (field.isEmpty) continue;
            best = max(best, _fuzzyFieldScore(q, field));
          }
          if (best > 0) {
            scored.add(_ScoredAirport(airport: a, score: best));
          }
        }

        scored.sort((a, b) => b.score.compareTo(a.score));

        if (scored.isNotEmpty) {
          _isFuzzyResult = true;
          final top = scored.first.airport;
          _fuzzyDidYouMean =
              '${top.city}${top.iataCode.isNotEmpty ? ' (${top.iataCode})' : ''}';
          _filteredAirports = scored.take(10).map((s) => s.airport).toList();
          log('[FlightAirportProvider] Fuzzy found ${scored.length} matches, top: $_fuzzyDidYouMean');
        }
      }
    }

    log('[FlightAirportProvider] Filtered results = ${_filteredAirports.length}');
    notifyListeners();
  }

  /// Accept a fuzzy suggestion — re-filter with the corrected city name.
  void acceptFuzzySuggestion(FlightAirportModel airport) {
    final corrected = airport.city.isNotEmpty ? airport.city : airport.airport;
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    filterAirports(corrected);
  }

  void clearFilter() {
    _searchQuery = '';
    _isFuzzyResult = false;
    _fuzzyDidYouMean = null;
    _filteredAirports = List.from(_airports);
    notifyListeners();
  }

  void retryFetch() {
    _airports = [];
    _filteredAirports = [];
    _error = null;
    fetchAirports();
  }

  // ── Fuzzy helpers ─────────────────────────────────────────────────────

  /// Score how well [query] matches a single [field]. Returns 0–100.
  static double _fuzzyFieldScore(String query, String field) {
    if (query == field) return 100;
    if (field.startsWith(query)) return 85 + (10 * query.length / field.length);
    if (field.contains(query)) return 70 + (10 * query.length / field.length);

    final dist = _levenshtein(query, field);
    final maxLen = max(query.length, field.length);
    final similarity = 1.0 - (dist / maxLen);
    if (similarity > 0.45) return similarity * 80;

    // Try per-word matching
    for (final word in field.split(RegExp(r'[\s,]+'))) {
      if (word.isEmpty) continue;
      final wDist = _levenshtein(query, word);
      final wMax = max(query.length, word.length);
      final wSim = 1.0 - (wDist / wMax);
      if (wSim > 0.55) return wSim * 75;
    }
    return 0;
  }

  /// Standard Levenshtein edit distance.
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }
    return prev[b.length];
  }
}

class _ScoredAirport {
  final FlightAirportModel airport;
  final double score;
  const _ScoredAirport({required this.airport, required this.score});
}
