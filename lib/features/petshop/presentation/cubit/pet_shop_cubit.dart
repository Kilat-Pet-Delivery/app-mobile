import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pet_shop_model.dart';
import '../../domain/repositories/pet_shop_repository.dart';

// State
abstract class PetShopState extends Equatable {
  const PetShopState();
  @override
  List<Object?> get props => [];
}

class PetShopInitial extends PetShopState {}

class PetShopLoading extends PetShopState {}

class PetShopLoaded extends PetShopState {
  final List<PetShopModel> shops;
  final String? activeCategory;
  const PetShopLoaded(this.shops, {this.activeCategory});
  @override
  List<Object?> get props => [shops.length, activeCategory];
}

class PetShopError extends PetShopState {
  final String message;
  const PetShopError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class PetShopCubit extends Cubit<PetShopState> {
  final PetShopRepository _repository;

  PetShopCubit(this._repository) : super(PetShopInitial());

  Future<void> loadPetShops({String? category}) async {
    emit(PetShopLoading());
    try {
      final shops = await _repository.listPetShops(category: category);
      emit(PetShopLoaded(shops, activeCategory: category));
    } catch (e) {
      emit(PetShopError(e.toString()));
    }
  }

  Future<void> filterByCategory(String? category) async {
    await loadPetShops(category: category);
  }
}
