Map<int, List<String>> normalizeAutomaticGroupTags(Object? raw) {
  if (raw is! Map) return const {};

  final normalized = <int, List<String>>{};
  for (final entry in raw.entries) {
    final key = entry.key is int
        ? entry.key as int
        : int.tryParse(entry.key.toString());
    final value = entry.value;
    if (key == null || value is! List) continue;

    normalized[key] = List<String>.unmodifiable(
      value.whereType<Object>().map((tag) => tag.toString()),
    );
  }

  return Map<int, List<String>>.unmodifiable(normalized);
}
