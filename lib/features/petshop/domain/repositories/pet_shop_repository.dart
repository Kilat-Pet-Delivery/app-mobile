import '../../data/models/pet_shop_model.dart';

abstract class PetShopRepository {
  Future<List<PetShopModel>> listPetShops({String? category});
  Future<PetShopModel> getPetShop(String id);
  Future<List<PetShopModel>> getNearbyPetShops(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  });
}
