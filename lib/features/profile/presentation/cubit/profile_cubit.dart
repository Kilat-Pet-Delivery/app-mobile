import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';

// State
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user.id, user.fullName, user.phone];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final UserModel user;
  const ProfileUpdating(this.user);
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final SecureStorageService _storage;

  ProfileCubit(this._authRepository, this._storage) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _authRepository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to load profile'));
    }
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(ProfileUpdating(current.user));
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;

      final user = await _authRepository.updateProfile(data);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileLoaded(current.user));
      emit(ProfileError('Failed to update profile'));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      await _storage.clearTokens();
    }
  }
}
