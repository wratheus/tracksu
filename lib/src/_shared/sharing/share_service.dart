import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tracksu/src/_shared/sharing/share_destination.dart';

import 'package:share_plus/share_plus.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';

/// One share dispatch across the app; no recipient or delivery tracking.
final class ShareService {
  Future<void>? _pending;

  Future<void> share(
    ShareTarget target, {
    required ShareDestination destination,
    Rect? origin,
  }) {
    return _pending ??= _dispatch(
      target,
      destination,
      origin,
    ).whenComplete(() => _pending = null);
  }

  Future<void> _dispatch(
    ShareTarget target,
    ShareDestination destination,
    Rect? origin,
  ) async {
    if (destination == ShareDestination.copy) {
      await Clipboard.setData(ClipboardData(text: target.uri.toString()));
      return;
    }
    if (destination == ShareDestination.system) {
      await _share(target, origin);
      return;
    }
    final Uri composer = switch (destination) {
      ShareDestination.telegram => Uri.https(
        't.me',
        '/share/url',
        <String, String>{'url': target.uri.toString(), 'text': target.title},
      ),
      ShareDestination.whatsapp => Uri.https('wa.me', '/', <String, String>{
        'text': '${target.title}\n${target.uri}',
      }),
      ShareDestination.facebook => Uri.https(
        'www.facebook.com',
        '/sharer/sharer.php',
        <String, String>{'u': target.uri.toString()},
      ),
      ShareDestination.x => Uri.https(
        'x.com',
        '/intent/tweet',
        <String, String>{'url': target.uri.toString(), 'text': target.title},
      ),
      _ => throw StateError('Unexpected share destination.'),
    };
    // The provider may open an installed app or its web composer/login page.
    if (!await launchUrl(composer, mode: LaunchMode.externalApplication)) {
      await _share(target, origin);
    }
  }

  Future<void> _share(ShareTarget target, Rect? origin) async {
    await SharePlus.instance.share(
      ShareParams(
        // Plain text does not request link preview metadata from the app.
        text: target.uri.toString(),
        subject: target.title,
        title: target.title,
        sharePositionOrigin: origin,
      ),
    );
    // Dismissed/unavailable result status is not a delivery failure.
  }
}
