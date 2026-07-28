abstract interface class OAuthCallbackLinkSource {
  Future<Uri?> getInitialUri();

  Stream<Uri> get uriStream;
}
