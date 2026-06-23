class ComlateFirebaseTableColumn {
  final String label;
  final List<String> keys;
  final String connector;
  final String? tooltip;
  final String Function(dynamic)? transformer;

  const ComlateFirebaseTableColumn({
    required this.label,
    required this.keys,
    this.connector = ' ',
    this.tooltip,
    this.transformer
  });
}