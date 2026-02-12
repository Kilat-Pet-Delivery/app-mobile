import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pet_shop_model.dart';
import '../../domain/repositories/pet_shop_repository.dart';

// State
abstract class PetShopDetailState extends Equatable {
  const PetShopDetailState();
  @override
  List<Object?> get props => [];
}

class PetShopDetailInitial extends PetShopDetailState {}

class PetShopDetailLoading extends PetShopDetailState {}

class PetShopDetailLoaded extends PetShopDetailState {
  final PetShopModel shop;
  const PetShopDetailLoaded(this.shop);
  @override
  List<Object?> get props => [shop.id];
}

class PetShopDetailError extends PetShopDetailState {
  final String message;
  const PetShopDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class PetShopDetailCubit extends Cubit<PetShopDetailState> {
  final PetShopRepository _repository;

  PetShopDetailCubit(this._repository) : super(PetShopDetailInitial());

  Future<void> loadPetShop(String id) async {
    emit(PetShopDetailLoading());
    try {
      final shop = await _repository.getPetShop(id);
      emit(PetShopDetailLoaded(shop));
    } catch (e) {
      emit(PetShopDetailError(e.toString()));
    }
  }
}
