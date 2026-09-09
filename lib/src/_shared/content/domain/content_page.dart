import 'package:tracksu/src/_shared/content/domain/content_document.dart';

/// A missing page is null. A present but unreadable page keeps its original URL.
final class ContentPage {
  const ContentPage({required this.uri, required this.document});
  final Uri uri;
  final ContentDocument? document;
}
