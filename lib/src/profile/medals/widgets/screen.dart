import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/_shared/sharing/share_button.dart';
import 'package:tracksu/src/_shared/sharing/share_target.dart';
import 'package:tracksu/src/profile/medals/bloc/bloc.dart';
import 'package:tracksu/src/profile/medals/domain/medal.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class MedalsScreen extends StatelessWidget {
  const MedalsScreen({required this.userId, super.key});
  final int userId;
  void _refresh(BuildContext context) {
    context.read<MedalsBloc>().add(const MedalsLoadRequested());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: UiText.titleLarge(context.t.profileMedals),
      actions: <Widget>[
        UiIconButton.standard(
          tooltip: context.t.profileRefresh,
          icon: Icons.refresh,
          onPressed: () => _refresh(context),
        ),
        ShareButton.icon(
          target: ShareTarget.medals(userId, context.t.profileMedals),
        ),
      ],
    ),
    body: SafeArea(
      child: BlocBuilder<MedalsBloc, MedalsState>(
        builder: (BuildContext context, MedalsState state) {
          if (state is MedalsLoading) {
            return UiLoading(label: context.t.medalsLoading);
          }
          if (state is MedalsError) {
            return UiContentState.error(
              title: context.t.medalsFailed,
              actionLabel: context.t.retry,
              onAction: () => _refresh(context),
            );
          }
          final MedalsLoaded loaded = state as MedalsLoaded;
          final List<EarnedMedal> medals = loaded.medals;
          if (medals.isEmpty && !loaded.refreshing && !loaded.refreshFailed) {
            return UiContentState.empty(title: context.t.medalsEmpty);
          }
          return CustomScrollView(
            slivers: <Widget>[
              if (loaded.refreshing)
                const SliverToBoxAdapter(child: LinearProgressIndicator()),
              if (loaded.refreshFailed)
                SliverToBoxAdapter(
                  child: UiContentState.error(
                    title: context.t.medalsFailed,
                    actionLabel: context.t.retry,
                    onAction: () => _refresh(context),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(UiSpace.lg),
                sliver: UiSliverCardList(
                  itemCount: medals.length,
                  itemBuilder: (BuildContext context, int index) {
                    final EarnedMedal medal = medals[index];
                    return UiSurface.card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: UiSpace.md,
                        children: <Widget>[
                          if (medal.imageUri != null)
                            UiImage(
                              image: NetworkImage(medal.imageUri.toString()),
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            )
                          else
                            const Icon(
                              Icons.workspace_premium_outlined,
                              size: 48,
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: UiSpace.sm,
                              children: <Widget>[
                                UiText.titleMedium(
                                  medal.name ??
                                      context.t.profileMedalId(medal.id),
                                ),
                                if (medal.description
                                    case final String description)
                                  UiText.bodyMedium(description),
                                UiText.bodySmall(
                                  DateFormat.yMMMd(
                                    Localizations.localeOf(context)
                                        .toLanguageTag(),
                                  ).format(medal.earnedAt.toLocal()),
                                  secondary: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
