import '../../data/models/tracking_model.dart';

abstract class TrackingRepository {
  Future<TrackingModel> getTracking(String bookingId);
  Future<String> getRouteGeoJSON(String bookingId);
}
