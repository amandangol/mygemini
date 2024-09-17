String getTimeAgo(DateTime dateTime) {
  Duration difference = DateTime.now().difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    int weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '${months}mo ago';
  } else {
    int years = (difference.inDays / 365).floor();
    return '${years}y ago';
  }
}
