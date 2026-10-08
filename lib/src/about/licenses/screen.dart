import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

/// One package and every license text registered for it.
@immutable
final class _PackageLicenses {
  const _PackageLicenses(this.name, this.entries);
  final String name;
  final List<LicenseEntry> entries;
}

/// Route form: the licenses list with its own app bar.
final class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(
        MaterialLocalizations.of(context).licensesPageTitle,
      ),
    ),
    body: const LicensesView(),
  );
}

/// Replaces Flutter's stock LicensePage: themed, searchable, explains why the
/// list exists, and opens each package's text in a sheet. Also embedded as
/// the "Licenses" tab of About.
final class LicensesView extends StatefulWidget {
  const LicensesView({super.key});
  @override
  State<LicensesView> createState() => _LicensesViewState();
}

final class _LicensesViewState extends State<LicensesView> {
  late final Future<List<_PackageLicenses>> _packages = _collect();
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _opening = false;

  static Future<List<_PackageLicenses>> _collect() async {
    final Map<String, List<LicenseEntry>> byPackage =
        <String, List<LicenseEntry>>{};
    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      for (final String package in entry.packages) {
        (byPackage[package] ??= <LicenseEntry>[]).add(entry);
      }
    }
    final List<String> names = byPackage.keys.toList()
      ..sort(
        (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
    return List<_PackageLicenses>.unmodifiable(<_PackageLicenses>[
      for (final String name in names) _PackageLicenses(name, byPackage[name]!),
    ]);
  }

  Future<void> _open(_PackageLicenses package) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await UiModal.scrollable<void>(
        context,
        title: package.name,
        builder: (_) => _LicenseText(package: package),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<_PackageLicenses>>(
    future: _packages,
    builder:
        (BuildContext context, AsyncSnapshot<List<_PackageLicenses>> snap) {
          final List<_PackageLicenses> all =
              snap.data ?? const <_PackageLicenses>[];
          final List<_PackageLicenses> visible = all
              .where(
                (_PackageLicenses item) =>
                    item.name.toLowerCase().contains(_query),
              )
              .toList(growable: false);
          return UiFrame.scroll(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: UiSpace.lg,
                  children: <Widget>[
                    UiSurface.tonal(
                      padding: const EdgeInsets.all(UiSpace.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: UiSpace.sm,
                        children: <Widget>[
                          UiText.headlineSmall(context.t.appTitle),
                          UiText.bodyMedium(
                            context.t.licensesIntro,
                            secondary: true,
                          ),
                          if (snap.hasData)
                            UiBadge.neutral(
                              context.t.licensesPackageCount(all.length),
                              icon: Icons.inventory_2_outlined,
                            ),
                        ],
                      ),
                    ),
                    UiSearchField(
                      controller: _search,
                      label: context.t.licensesSearch,
                      clearLabel: context.t.searchClear,
                      onChanged: (String value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: UiSpace.md)),
              if (!snap.hasData)
                SliverToBoxAdapter(
                  child: UiPageSkeleton.list(
                    label: MaterialLocalizations.of(context).licensesPageTitle,
                  ),
                )
              else if (visible.isEmpty)
                SliverToBoxAdapter(
                  child: UiContentState.empty(title: context.t.licensesNoMatch),
                )
              else
                SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final _PackageLicenses item = visible[index];
                    return UiTile.navigation(
                      key: ValueKey<String>(item.name),
                      title: item.name,
                      subtitle: MaterialLocalizations.of(context)
                          .licensesPackageDetailText(item.entries.length),
                      onTap: _opening ? null : () => _open(item),
                    );
                  },
                ),
            ],
          );
        },
  );
}

final class _LicenseText extends StatelessWidget {
  const _LicenseText({required this.package});
  final _PackageLicenses package;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(height: 1.5);
    final List<Widget> blocks = <Widget>[];
    for (int i = 0; i < package.entries.length; i++) {
      if (i > 0) blocks.add(const Divider(height: UiSpace.xxl));
      for (final LicenseParagraph paragraph in package.entries[i].paragraphs) {
        blocks.add(
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: paragraph.indent == LicenseParagraph.centeredIndent
                  ? 0
                  : UiSpace.lg * paragraph.indent,
              bottom: UiSpace.sm,
            ),
            child: Text(
              paragraph.text,
              style: style,
              textAlign: paragraph.indent == LicenseParagraph.centeredIndent
                  ? TextAlign.center
                  : TextAlign.start,
            ),
          ),
        );
      }
    }
    return SelectionArea(
      child: ListView(
        primary: true,
        padding: const EdgeInsets.fromLTRB(
          UiSpace.lg,
          0,
          UiSpace.lg,
          UiSpace.xl,
        ),
        children: blocks,
      ),
    );
  }
}
