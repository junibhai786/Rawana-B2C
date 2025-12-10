List<T> parseMapOrList<T>(
  dynamic json,
  T Function(dynamic) converter,
) {
  if (json == null) return [];

  if (json is List) {
    return json.map((e) => converter(e)).toList();
  }

  if (json is Map) {
    return json.values.map((e) => converter(e)).toList();
  }

  return [];
}
