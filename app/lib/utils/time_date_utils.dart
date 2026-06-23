import 'package:timeago/timeago.dart' as timeago;

class TimeDateUtils {
  static String formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String timeAgo(DateTime? createdAt, {String locale = 'en'}) {
    if (createdAt == null) return '';
    return timeago.format(createdAt, locale: locale);
  }
}
