class RouteDurationFormatter {
  const RouteDurationFormatter._();

  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}min';
    if (minutes > 0) return '${minutes}min ${seconds}s';

    return '${seconds}s';
  }
}
