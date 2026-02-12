import '../../data/models/runner_model.dart';

abstract class RunnerRepository {
  Future<List<RunnerModel>> getNearbyRunners(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  });
}
