class HistoryItem {
  final String title;
  final String type; // 'drug', 'disease', or 'terminology'
  final DateTime timestamp;
  final String description;

  HistoryItem({
    required this.title,
    required this.type,
    required this.timestamp,
    required this.description,
  });
}
