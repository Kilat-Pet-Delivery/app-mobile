import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/runner_model.dart';
import '../../domain/repositories/runner_repository.dart';

// State
abstract class NearbyRunnersState extends Equatable {
  const NearbyRunnersState();
  @override
  List<Object?> get props => [];
}

class NearbyRunnersInitial extends NearbyRunnersState {}

class NearbyRunnersLoading extends NearbyRunnersState {}

class NearbyRunnersLoaded extends NearbyRunnersState {
  final List<RunnerModel> runners;
  const NearbyRunnersLoaded(this.runners);
  @override
  List<Object?> get props => [runners.length];
}

class NearbyRunnersError extends NearbyRunnersState {
  final String message;
  const NearbyRunnersError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class NearbyRunnersCubit extends Cubit<NearbyRunnersState> {
  final RunnerRepository _repository;

  NearbyRunnersCubit(this._repository) : super(NearbyRunnersInitial());

  Future<void> loadNearbyRunners(double lat, double lng,
      {double radiusKm = 5}) async {
    emit(NearbyRunnersLoading());
    try {
      final runners =
          await _repository.getNearbyRunners(lat, lng, radiusKm: radiusKm);
      emit(NearbyRunnersLoaded(runners));
    } catch (e) {
      emit(NearbyRunnersError(e.toString()));
    }
  }
}
