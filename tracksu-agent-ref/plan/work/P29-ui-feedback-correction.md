# P29 — UI/media corrections

Status: awaiting_manual_check. Local checkpoint commits approved by user on
2026-10-02; no push/deploy and existing untracked ios/ excluded. Automated tests
are explicitly prohibited. Commit does not replace user acceptance.

## C1: public team authorization

Allow only HTTPS GET osu.ppy.sh /api/v2/teams/{positive-id}[/{osu|taiko|fruits|mania}].
Before the correction, the auth interceptor raised StateError before network.
Parent live iPhone17 QA previously confirmed TeamLoaded for team1/team2; team2
loaded in all four rulesets without failure. No broader host/method/auth bypass.
Formatter/analyzer/build passed on the matching correction artifact; no tests.

Remaining: shared UI transitions, content image sizing/failures and iOS Vorbis
are subsequent checkpoints, not implemented by this commit. Full user QA remains
open. Existing SDK3.47.5 pin and untracked iOS host are preserved.
