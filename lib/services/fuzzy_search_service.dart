import 'dart:math';
import 'package:moonbnd/modals/hotel_destination_model.dart';

/// Lightweight fuzzy search service for typo-tolerant destination matching.
///
/// Uses Levenshtein distance + prefix/substring/code matching to rank
/// results when the API returns empty for misspelled queries like
/// "dubaai", "duabi", "dupia", "dxb".
///
/// The destination pool is seeded with popular destinations and enriched
/// automatically from every successful API response.
class FuzzySearchService {
  FuzzySearchService._();
  static final FuzzySearchService instance = FuzzySearchService._();

  /// Pool of known destinations (seeded + enriched from API).
  final List<HotelDestinationResult> _destinationPool = [
    ..._seedDestinations,
  ];

  // ── Public API ──────────────────────────────────────────────────────────

  /// Call after every successful API search to grow the pool.
  void cacheDestinations(List<HotelDestinationResult> results) {
    for (final r in results) {
      final key = _poolKey(r);
      if (key.isNotEmpty && !_destinationPool.any((d) => _poolKey(d) == key)) {
        _destinationPool.add(r);
      }
    }
  }

  /// Returns fuzzy-matched destinations ranked by relevance.
  /// [query] is the raw user input (e.g. "dubaai").
  /// [maxResults] caps the output list length.
  List<FuzzyMatch> search(String query, {int maxResults = 10}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final scored = <FuzzyMatch>[];

    for (final dest in _destinationPool) {
      final score = _score(q, dest);
      if (score > 0) {
        scored.add(FuzzyMatch(destination: dest, score: score));
      }
    }

    // Sort descending by score
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(maxResults).toList();
  }

  // ── Scoring ─────────────────────────────────────────────────────────────

  /// Composite score for how well [query] matches [dest].
  /// Higher = better match. Returns 0 for clearly unrelated items.
  double _score(String query, HotelDestinationResult dest) {
    double best = 0;

    // Match against each searchable field
    final fields = <String>[
      dest.destination ?? '',
      dest.city ?? '',
      dest.displayName ?? '',
      dest.country ?? '',
      dest.region ?? '',
    ];

    for (final field in fields) {
      if (field.isEmpty) continue;
      final f = field.toLowerCase();
      final s = _fieldScore(query, f);
      if (s > best) best = s;
    }

    // Bonus: exact code match (e.g. "dxb" → DXB location code)
    final code = (dest.location ?? '').toLowerCase();
    if (code.isNotEmpty && code == query) {
      best = max(best, 95);
    } else if (code.isNotEmpty && code.startsWith(query)) {
      best = max(best, 80);
    }

    // Bonus: country code match
    final cc = (dest.countryCode ?? '').toLowerCase();
    if (cc.isNotEmpty && cc == query) {
      best = max(best, 60);
    }

    return best;
  }

  /// Score a single [query] against a single [field].
  double _fieldScore(String query, String field) {
    // Exact match
    if (query == field) return 100;

    // Starts-with (strong signal)
    if (field.startsWith(query)) {
      return 85 + (10 * query.length / field.length);
    }

    // Contains as substring
    if (field.contains(query)) {
      return 70 + (10 * query.length / field.length);
    }

    // Levenshtein-based similarity
    final distance = _levenshtein(query, field);
    final maxLen = max(query.length, field.length);
    final similarity = 1.0 - (distance / maxLen);

    // Only consider if similarity is reasonable (> 0.45)
    if (similarity > 0.45) {
      return similarity * 80; // max 80 for fuzzy matches
    }

    // Try matching against each word in the field
    final words = field.split(RegExp(r'[\s,]+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      final wDist = _levenshtein(query, word);
      final wMax = max(query.length, word.length);
      final wSim = 1.0 - (wDist / wMax);
      if (wSim > 0.55) {
        return wSim * 75;
      }
    }

    return 0;
  }

  // ── Levenshtein Distance ────────────────────────────────────────────────

  /// Standard Levenshtein edit distance between two strings.
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    // Use two-row optimization for memory efficiency
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);

    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(
          min(curr[j - 1] + 1, prev[j] + 1),
          prev[j - 1] + cost,
        );
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }

    return prev[b.length];
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  String _poolKey(HotelDestinationResult r) =>
      '${(r.destination ?? '').toLowerCase()}_${(r.countryCode ?? '').toLowerCase()}';

  // ── Seed Data ───────────────────────────────────────────────────────────

  /// Popular destinations pre-loaded so fuzzy works from first launch.
  static final List<HotelDestinationResult> _seedDestinations = [
    _seed('city', 'Dubai', 'Dubai', 'UAE', 'AE', 'DXB', 'Middle East',
        'Dubai, UAE'),
    _seed('city', 'Abu Dhabi', 'Abu Dhabi', 'UAE', 'AE', 'AUH', 'Middle East',
        'Abu Dhabi, UAE'),
    _seed('city', 'Sharjah', 'Sharjah', 'UAE', 'AE', 'SHJ', 'Middle East',
        'Sharjah, UAE'),
    _seed('city', 'London', 'London', 'United Kingdom', 'GB', 'LHR', 'Europe',
        'London, United Kingdom'),
    _seed('city', 'Paris', 'Paris', 'France', 'FR', 'CDG', 'Europe',
        'Paris, France'),
    _seed('city', 'New York', 'New York', 'United States', 'US', 'JFK',
        'North America', 'New York, United States'),
    _seed('city', 'Istanbul', 'Istanbul', 'Turkey', 'TR', 'IST', 'Europe',
        'Istanbul, Turkey'),
    _seed('city', 'Bangkok', 'Bangkok', 'Thailand', 'TH', 'BKK', 'Asia',
        'Bangkok, Thailand'),
    _seed('city', 'Singapore', 'Singapore', 'Singapore', 'SG', 'SIN', 'Asia',
        'Singapore, Singapore'),
    _seed('city', 'Kuala Lumpur', 'Kuala Lumpur', 'Malaysia', 'MY', 'KUL',
        'Asia', 'Kuala Lumpur, Malaysia'),
    _seed(
        'city', 'Tokyo', 'Tokyo', 'Japan', 'JP', 'NRT', 'Asia', 'Tokyo, Japan'),
    _seed('city', 'Maldives', 'Malé', 'Maldives', 'MV', 'MLE', 'Asia',
        'Malé, Maldives'),
    _seed('city', 'Bali', 'Bali', 'Indonesia', 'ID', 'DPS', 'Asia',
        'Bali, Indonesia'),
    _seed('city', 'Cairo', 'Cairo', 'Egypt', 'EG', 'CAI', 'Africa',
        'Cairo, Egypt'),
    _seed(
        'city', 'Rome', 'Rome', 'Italy', 'IT', 'FCO', 'Europe', 'Rome, Italy'),
    _seed('city', 'Barcelona', 'Barcelona', 'Spain', 'ES', 'BCN', 'Europe',
        'Barcelona, Spain'),
    _seed('city', 'Amsterdam', 'Amsterdam', 'Netherlands', 'NL', 'AMS',
        'Europe', 'Amsterdam, Netherlands'),
    _seed('city', 'Doha', 'Doha', 'Qatar', 'QA', 'DOH', 'Middle East',
        'Doha, Qatar'),
    _seed('city', 'Riyadh', 'Riyadh', 'Saudi Arabia', 'SA', 'RUH',
        'Middle East', 'Riyadh, Saudi Arabia'),
    _seed('city', 'Jeddah', 'Jeddah', 'Saudi Arabia', 'SA', 'JED',
        'Middle East', 'Jeddah, Saudi Arabia'),
    _seed('city', 'Muscat', 'Muscat', 'Oman', 'OM', 'MCT', 'Middle East',
        'Muscat, Oman'),
    _seed('city', 'Bahrain', 'Manama', 'Bahrain', 'BH', 'BAH', 'Middle East',
        'Manama, Bahrain'),
    _seed('city', 'Kuwait City', 'Kuwait City', 'Kuwait', 'KW', 'KWI',
        'Middle East', 'Kuwait City, Kuwait'),
    _seed('city', 'Mumbai', 'Mumbai', 'India', 'IN', 'BOM', 'Asia',
        'Mumbai, India'),
    _seed(
        'city', 'Delhi', 'Delhi', 'India', 'IN', 'DEL', 'Asia', 'Delhi, India'),
    _seed('city', 'Goa', 'Goa', 'India', 'IN', 'GOI', 'Asia', 'Goa, India'),
    _seed('city', 'Colombo', 'Colombo', 'Sri Lanka', 'LK', 'CMB', 'Asia',
        'Colombo, Sri Lanka'),
    _seed('city', 'Tbilisi', 'Tbilisi', 'Georgia', 'GE', 'TBS', 'Europe',
        'Tbilisi, Georgia'),
    _seed('city', 'Baku', 'Baku', 'Azerbaijan', 'AZ', 'GYD', 'Asia',
        'Baku, Azerbaijan'),
    _seed('city', 'Phuket', 'Phuket', 'Thailand', 'TH', 'HKT', 'Asia',
        'Phuket, Thailand'),
    _seed('city', 'Hong Kong', 'Hong Kong', 'China', 'HK', 'HKG', 'Asia',
        'Hong Kong, China'),
    _seed('city', 'Seoul', 'Seoul', 'South Korea', 'KR', 'ICN', 'Asia',
        'Seoul, South Korea'),
    _seed('city', 'Zurich', 'Zurich', 'Switzerland', 'CH', 'ZRH', 'Europe',
        'Zurich, Switzerland'),
    _seed('city', 'Berlin', 'Berlin', 'Germany', 'DE', 'BER', 'Europe',
        'Berlin, Germany'),
    _seed('city', 'Athens', 'Athens', 'Greece', 'GR', 'ATH', 'Europe',
        'Athens, Greece'),
    _seed('city', 'Marrakech', 'Marrakech', 'Morocco', 'MA', 'RAK', 'Africa',
        'Marrakech, Morocco'),
    _seed('city', 'Nairobi', 'Nairobi', 'Kenya', 'KE', 'NBO', 'Africa',
        'Nairobi, Kenya'),
    _seed('city', 'Cape Town', 'Cape Town', 'South Africa', 'ZA', 'CPT',
        'Africa', 'Cape Town, South Africa'),
    _seed('city', 'Sydney', 'Sydney', 'Australia', 'AU', 'SYD', 'Oceania',
        'Sydney, Australia'),
    _seed('city', 'Melbourne', 'Melbourne', 'Australia', 'AU', 'MEL', 'Oceania',
        'Melbourne, Australia'),
  ];

  static HotelDestinationResult _seed(
    String type,
    String destination,
    String city,
    String country,
    String countryCode,
    String location,
    String region,
    String displayName,
  ) =>
      HotelDestinationResult(
        type: type,
        destination: destination,
        city: city,
        country: country,
        countryCode: countryCode,
        location: location,
        region: region,
        displayName: displayName,
      );
}

/// A single fuzzy match result with its relevance score.
class FuzzyMatch {
  final HotelDestinationResult destination;

  /// 0–100 relevance score. Higher = closer match.
  final double score;

  const FuzzyMatch({required this.destination, required this.score});
}
