import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';
import 'package:tracksu_ui/src/widgets/content_state.dart';
import 'package:tracksu_ui/src/widgets/surface.dart';

enum _SkeletonShape { profile, list, news, article }

/// Initial load only. Never replaces usable content during revalidation.
/// One controller per page pulses all placeholders together; reduced motion
/// and inactive tickers (TickerMode) keep it static.
/// A fixed small number of placeholders; never sized by expected content.
final class UiPageSkeleton extends StatefulWidget {
  const UiPageSkeleton.profile({required this.label, super.key})
    : _shape = _SkeletonShape.profile;
  const UiPageSkeleton.list({required this.label, super.key})
    : _shape = _SkeletonShape.list;

  /// News cards: 16:9 cover, date, title, author and a short excerpt.
  const UiPageSkeleton.news({required this.label, super.key})
    : _shape = _SkeletonShape.news;

  /// A long-form article: headline, byline and paragraphs.
  const UiPageSkeleton.article({required this.label, super.key})
    : _shape = _SkeletonShape.article;
  final String label;
  final _SkeletonShape _shape;

  @override
  State<UiPageSkeleton> createState() => _UiPageSkeletonState();
}

final class _UiPageSkeletonState extends State<UiPageSkeleton>
    with TickerProviderStateMixin {
  // Enters after a beat: a load that finishes quickly (cache, fast network)
  // never flashes placeholders, and a slow one fades them in softly.
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: UiMotion.skeletonEntry,
  );
  late final Animation<double> _entryOpacity = _entry.drive(
    CurveTween(curve: const Interval(0.4, 1, curve: Curves.easeOut)),
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: UiMotion.skeletonPulse,
  );
  late final Animation<double> _opacity = _controller.drive(
    Tween<double>(
      begin: 1,
      end: .55,
    ).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
      _entry.value = 1;
    } else {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
      if (_entry.isDismissed) _entry.forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    liveRegion: true,
    child: FadeTransition(
      opacity: _entryOpacity,
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.md,
            children: switch (widget._shape) {
              _SkeletonShape.profile || _SkeletonShape.list => <Widget>[
                if (widget._shape == _SkeletonShape.profile)
                  const UiSkeleton.block(height: 160),
                for (int i = 0; i < 3; i++) const _RowSkeleton(),
              ],
              _SkeletonShape.news => <Widget>[
                for (int i = 0; i < 2; i++) const _NewsCardSkeleton(),
              ],
              _SkeletonShape.article => const <Widget>[_ArticleSkeleton()],
            },
          ),
        ),
      ),
    ),
  );
}

final class _Line extends StatelessWidget {
  const _Line(this.widthFactor);
  final double widthFactor;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    alignment: AlignmentDirectional.centerStart,
    child: const UiSkeleton.line(),
  );
}

final class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) => const UiSurface.card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.md,
      children: <Widget>[
        UiSkeleton.block(height: 56, width: 56),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.md,
            children: <Widget>[UiSkeleton.line(), _Line(.65), _Line(.4)],
          ),
        ),
      ],
    ),
  );
}

/// Mirrors OsuNewsCard: edge-to-edge cover, then a padded text column.
final class _NewsCardSkeleton extends StatelessWidget {
  const _NewsCardSkeleton();

  @override
  Widget build(BuildContext context) => UiSurface.card(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(UiSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.sm,
            children: <Widget>[
              _Line(.3),
              UiSkeleton.block(height: 20),
              _Line(.7),
              _Line(.25),
              UiSkeleton.line(),
              _Line(.85),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Mirrors the reader heading and the first paragraphs, without a card.
final class _ArticleSkeleton extends StatelessWidget {
  const _ArticleSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: UiSpace.md,
    children: <Widget>[
      UiSkeleton.block(height: 28),
      _Line(.6),
      _Line(.35),
      Padding(
        padding: EdgeInsets.only(top: UiSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.sm,
          children: <Widget>[
            UiSkeleton.line(),
            UiSkeleton.line(),
            _Line(.8),
            UiSkeleton.line(),
            _Line(.55),
          ],
        ),
      ),
      UiSkeleton.block(height: 160),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: UiSpace.sm,
        children: <Widget>[UiSkeleton.line(), _Line(.9), _Line(.4)],
      ),
    ],
  );
}
