import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/media/widgets/app_media.dart';
import 'package:tracksu/src/about/domain/build_info.dart';
import 'package:tracksu/src/about/licenses/screen.dart';
import 'package:tracksu/src/profile/domain/profile_params.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu_ui/tracksu_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// osu! accounts of the people behind Tracksu, in display order.
const List<({int id, String name, bool author})> _people =
    <({int id, String name, bool author})>[
      (id: 12288747, name: 'Repentance', author: true),
      (id: 24581198, name: 'Sgooll', author: false),
    ];

/// About in four calm tabs (same segmented control as the profile):
/// the app and its build, the authors, the history, the licenses.
final class AboutScreen extends StatelessWidget {
  const AboutScreen({required this.info, required this.onRetry, super.key});
  final Future<AppBuildInfo> info;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(title: UiText.titleLarge(context.t.aboutTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            const _AboutTabs(),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _AppTab(info: info, onRetry: onRetry),
                  const _AuthorsTab(),
                  const _HistoryTab(),
                  const LicensesView(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _AboutTabs extends StatelessWidget {
  const _AboutTabs();

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final List<(IconData, String)> tabs = <(IconData, String)>[
      (Icons.info_outline_rounded, context.t.aboutTabApp),
      (Icons.people_outline_rounded, context.t.aboutTabAuthors),
      (Icons.history_rounded, context.t.aboutTabHistory),
      (Icons.description_outlined, context.t.aboutTabLicenses),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiSpace.lg,
        UiSpace.sm,
        UiSpace.lg,
        UiSpace.xs,
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) => UiSegmentedControl<int>(
          selected: controller.index,
          segments: <UiSegment<int>>[
            for (int i = 0; i < tabs.length; i++)
              UiSegment<int>(
                value: i,
                label: tabs[i].$2,
                icon: Icon(tabs[i].$1),
              ),
          ],
          onChanged: controller.animateTo,
        ),
      ),
    );
  }
}

Future<void> _openLink(BuildContext context, Uri uri) async {
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      UiFeedback.snack(context, message: context.t.aboutLinkFailed);
    }
  } on Object {
    if (context.mounted) {
      UiFeedback.snack(context, message: context.t.aboutLinkFailed);
    }
  }
}

final class _AppTab extends StatelessWidget {
  const _AppTab({required this.info, required this.onRetry});
  final Future<AppBuildInfo> info;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => UiFrame.scroll(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.xl,
          children: <Widget>[
            UiSurface.tonal(
              padding: const EdgeInsets.all(UiSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: UiSpace.md,
                children: <Widget>[
                  UiText.headlineLarge(context.t.appTitle),
                  UiText.bodyLarge(context.t.aboutDescription),
                  FutureBuilder<AppBuildInfo>(
                    future: info,
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<AppBuildInfo> snapshot,
                        ) => switch (snapshot) {
                          AsyncSnapshot<AppBuildInfo>(
                            connectionState: ConnectionState.done,
                            hasData: true,
                            requireData: final AppBuildInfo data,
                          ) =>
                            SelectionArea(
                              child: UiBadge.neutral(
                                context.t.aboutVersion(
                                  data.version,
                                  data.buildNumber,
                                ),
                                icon: Icons.tag_rounded,
                              ),
                            ),
                          AsyncSnapshot<AppBuildInfo>(
                            connectionState: ConnectionState.done,
                          ) =>
                            UiButton.text(
                              label: context.t.aboutBuildUnavailable,
                              icon: Icons.refresh,
                              onPressed: onRetry,
                            ),
                          _ => const SizedBox(height: 24),
                        },
                  ),
                ],
              ),
            ),
            UiListGroup(
              footer: context.t.aboutUnofficial,
              children: <Widget>[
                UiTile.value(
                  title: context.t.aboutProject,
                  value: 'GitHub',
                  leading: const UiTileIcon(Icons.code),
                  onTap: () => _openLink(
                    context,
                    Uri.https('github.com', '/wratheus/tracksu'),
                  ),
                ),
                UiTile.value(
                  title: context.t.aboutOsu,
                  value: 'osu.ppy.sh',
                  leading: const UiTileIcon(Icons.open_in_new),
                  onTap: () => _openLink(context, Uri.https('osu.ppy.sh')),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

final class _AuthorsTab extends StatelessWidget {
  const _AuthorsTab();

  @override
  Widget build(BuildContext context) => UiFrame.scroll(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: UiSpace.lg,
          children: <Widget>[
            UiText.bodyLarge(context.t.aboutAuthorsIntro, secondary: true),
            UiListGroup(
              children: <Widget>[
                for (final ({int id, String name, bool author}) person
                    in _people)
                  UiTile.navigation(
                    title: person.name,
                    subtitle: person.author
                        ? context.t.aboutRoleAuthor
                        : context.t.aboutRoleCoauthor,
                    // Public osu! avatar CDN, same host as API avatars.
                    leading: UiAvatar.small(
                      name: person.name,
                      image: AppMedia.image(
                        context,
                        Uri.https('a.ppy.sh', '/${person.id}'),
                      ),
                    ),
                    onTap: () => DepsScope.of(context).appRouter.openProfile(
                      context,
                      ProfileParams(
                        user: ProfileUserId(person.id),
                        ruleset: ProfileRuleset.osu,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

final class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final List<(String?, String, String)> steps = <(String?, String, String)>[
      ('2021', context.t.aboutHistoryV1Title, context.t.aboutHistoryV1Body),
      (null, context.t.aboutHistoryV2Title, context.t.aboutHistoryV2Body),
      ('2026', context.t.aboutHistoryV3Title, context.t.aboutHistoryV3Body),
    ];
    return UiFrame.scroll(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: UiSpace.lg,
            children: <Widget>[
              UiText.bodyLarge(context.t.aboutHistoryIntro, secondary: true),
              for (int i = 0; i < steps.length; i++)
                _TimelineStep(
                  year: steps[i].$1,
                  title: steps[i].$2,
                  body: steps[i].$3,
                  current: i == steps.length - 1,
                ),
              UiSurface.tonal(
                padding: const EdgeInsets.all(UiSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: UiSpace.sm,
                  children: <Widget>[
                    UiText.titleMedium(context.t.aboutThanksTitle),
                    UiText.bodyMedium(context.t.aboutThanksBody),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One version: a dot on the left (filled for the current one), the year
/// as a small badge, title and a short paragraph.
final class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.year,
    required this.title,
    required this.body,
    required this.current,
  });
  final String? year;
  final String title;
  final String body;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: UiSpace.md,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: UiSpace.lg),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: current ? colors.primary : Colors.transparent,
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: const SizedBox.square(dimension: 12),
          ),
        ),
        Expanded(
          child: UiSurface.card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: UiSpace.sm,
              children: <Widget>[
                if (year case final String label)
                  UiBadge.accent(label, icon: Icons.event_outlined),
                UiText.titleMedium(title),
                UiText.bodyMedium(body, secondary: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
