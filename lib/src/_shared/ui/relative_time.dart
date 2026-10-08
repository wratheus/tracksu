import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';

/// "5 min ago" up to a week, then the local date. Used by comments and
/// profile activity.
String relativeTime(BuildContext context, DateTime at, {DateTime? now}) {
  final Duration age = (now ?? DateTime.now()).toUtc().difference(at);
  if (age.inMinutes < 1) return context.t.commentsJustNow;
  if (age.inHours < 1) return context.t.commentsMinutesAgo(age.inMinutes);
  if (age.inDays < 1) return context.t.commentsHoursAgo(age.inHours);
  if (age.inDays < 7) return context.t.commentsDaysAgo(age.inDays);
  return DateFormat.yMMMd(context.t.localeName).format(at.toLocal());
}
