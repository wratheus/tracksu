import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/about/domain/build_info.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

final class AboutScreen extends StatefulWidget {
  const AboutScreen({required this.info, required this.onRetry, super.key});
  final Future<AppBuildInfo> info;
  final VoidCallback onRetry;
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

final class _AboutScreenState extends State<AboutScreen> {
  bool _opening = false;

  Future<void> _open(Uri uri) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        UiFeedback.snack(context, message: context.t.aboutLinkFailed);
      }
    } on Object {
      if (mounted) {
        UiFeedback.snack(context, message: context.t.aboutLinkFailed);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _licenses() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter.openLicenses(context);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: UiText.titleLarge(context.t.aboutTitle)),
    body: UiFrame.scroll(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.xl,
            children: <Widget>[
              UiSurface.card(
                padding: const EdgeInsets.all(UiSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: UiSpace.md,
                  children: <Widget>[
                    UiText.headlineLarge(context.t.appTitle),
                    UiText.bodyLarge(
                      context.t.aboutDescription,
                      secondary: true,
                    ),
                    const Divider(),
                    UiText.bodySmall(
                      context.t.aboutUnofficial,
                      secondary: true,
                    ),
                  ],
                ),
              ),
              UiSection(
                title: context.t.aboutBuild,
                child: UiSurface.inset(
                  child: FutureBuilder<AppBuildInfo>(
                    future: widget.info,
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<AppBuildInfo> snapshot,
                        ) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return LinearProgressIndicator(
                              semanticsLabel: context.t.aboutBuild,
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: UiSpace.sm,
                              children: <Widget>[
                                UiText.bodyMedium(
                                  context.t.aboutBuildUnavailable,
                                ),
                                UiButton.text(
                                  label: context.t.retry,
                                  onPressed: widget.onRetry,
                                ),
                              ],
                            );
                          }
                          final AppBuildInfo info = snapshot.requireData;
                          return SelectionArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: UiSpace.sm,
                              children: <Widget>[
                                UiText.titleMedium(
                                  context.t.aboutVersion(
                                    info.version,
                                    info.buildNumber,
                                  ),
                                ),
                                UiText.bodySmall(
                                  info.packageName,
                                  secondary: true,
                                ),
                              ],
                            ),
                          );
                        },
                  ),
                ),
              ),
              UiSurface.card(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    UiTile.navigation(
                      title: context.t.aboutProject,
                      subtitle: 'github.com/wratheus/tracksu',
                      leading: const Icon(Icons.code),
                      onTap: _opening
                          ? null
                          : () => _open(
                              Uri.https('github.com', '/wratheus/tracksu'),
                            ),
                    ),
                    UiTile.navigation(
                      title: context.t.aboutOsu,
                      subtitle: 'osu.ppy.sh',
                      leading: const Icon(Icons.open_in_new),
                      onTap: _opening
                          ? null
                          : () => _open(Uri.https('osu.ppy.sh')),
                    ),
                    const Divider(
                      height: 1,
                      indent: UiSpace.lg,
                      endIndent: UiSpace.lg,
                    ),
                    UiTile.navigation(
                      title: MaterialLocalizations.of(context)
                          .licensesPageTitle,
                      subtitle: context.t.aboutLicensesDescription,
                      leading: const Icon(Icons.description_outlined),
                      onTap: _opening ? null : _licenses,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
