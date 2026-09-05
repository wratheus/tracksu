/// Public browser links only; never forwards app API credentials.
abstract final class NewsLink {
  static Uri? resolve(String value, {required Uri base}) {
    final Uri? reference = Uri.tryParse(value.trim());
    if (reference == null || value.trim().isEmpty) return null;
    final Uri uri = base.resolveUri(reference);
    if (uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }
}
