import 'package:tracksu/src/profile/medals/domain/medal.dart';

abstract interface class MedalsRepository {
  Future<List<EarnedMedal>> load(int userId);
  void cancelPending();
}
