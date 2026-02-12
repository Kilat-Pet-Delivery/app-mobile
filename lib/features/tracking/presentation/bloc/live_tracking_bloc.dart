import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/websocket/ws_manager.dart';
import '../../data/models/tracking_model.dart';
import '../../domain/repositories/tracking_repository.dart';

// Events
abstract class LiveTrackingEvent extends Equatable {
  const LiveTrackingEvent();
  @override
  List<Object?> get props => [];
}

class LiveTrackingStarted extends LiveTrackingEvent {
  final String bookingId;
  const LiveTrackingStarted(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class LiveTrackingStopped extends LiveTrackingEvent {}

class _TrackingUpdateReceived extends LiveTrackingEvent {
  final TrackingUpdate update;
  const _TrackingUpdateReceived(this.update);
}

class _TrackingConnectionError extends LiveTrackingEvent {
  final String error;
  const _TrackingConnectionError(this.error);
}

// State
class LiveTrackingState extends Equatable {
  final TrackingModel? tracking;
  final TrackingUpdate? latestUpdate;
  final List<LatLng> routePoints;
  final bool isConnected;
  final bool isLoading;
  final String? errorMessage;

  const LiveTrackingState({
    this.tracking,
    this.latestUpdate,
    this.routePoints = const [],
    this.isConnected = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LiveTrackingState copyWith({
    TrackingModel? tracking,
    TrackingUpdate? latestUpdate,
    List<LatLng>? routePoints,
    bool? isConnected,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LiveTrackingState(
      tracking: tracking ?? this.tracking,
      latestUpdate: latestUpdate ?? this.latestUpdate,
      routePoints: routePoints ?? this.routePoints,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [tracking?.id, latestUpdate?.timestamp, routePoints.length, isConnected, isLoading];
}

// Bloc
class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final TrackingRepository _trackingRepository;
  final WebSocketManager _wsManager;
  StreamSubscription<TrackingUpdate>? _wsSubscription;

  LiveTrackingBloc(this._trackingRepository, this._wsManager)
      : super(const LiveTrackingState()) {
    on<LiveTrackingStarted>(_onStarted);
    on<LiveTrackingStopped>(_onStopped);
    on<_TrackingUpdateReceived>(_onUpdateReceived);
    on<_TrackingConnectionError>(_onConnectionError);
  }

  Future<void> _onStarted(
    LiveTrackingStarted event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load initial tracking data
      final tracking =
          await _trackingRepository.getTracking(event.bookingId);
      final routePoints = tracking.waypoints
          .map((w) => LatLng(w.latitude, w.longitude))
          .toList();

      emit(state.copyWith(
        tracking: tracking,
        routePoints: routePoints,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tracking data',
      ));
    }

    // Connect WebSocket
    final stream = _wsManager.connect(event.bookingId);
    _wsSubscription = stream.listen(
      (update) => add(_TrackingUpdateReceived(update)),
      onError: (error) => add(_TrackingConnectionError(error.toString())),
    );
    emit(state.copyWith(isConnected: true));
  }

  void _onStopped(
    LiveTrackingStopped event,
    Emitter<LiveTrackingState> emit,
  ) {
    _wsSubscription?.cancel();
    _wsManager.disconnect();
    emit(state.copyWith(isConnected: false));
  }

  void _onUpdateReceived(
    _TrackingUpdateReceived event,
    Emitter<LiveTrackingState> emit,
  ) {
    final newPoint =
        LatLng(event.update.latitude, event.update.longitude);
    emit(state.copyWith(
      latestUpdate: event.update,
      routePoints: [...state.routePoints, newPoint],
      isConnected: true,
    ));
  }

  void _onConnectionError(
    _TrackingConnectionError event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      isConnected: false,
      errorMessage: event.error,
    ));
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _wsManager.disconnect();
    return super.close();
  }
}
