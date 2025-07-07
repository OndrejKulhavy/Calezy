import 'package:calezy/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_entity.dart';

class ProductsRepository {
  final OFFDataSource _offDataSource;

  ProductsRepository(this._offDataSource);

  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    final offWordResponse =
        await _offDataSource.fetchSearchWordResults(searchString);

    final products = offWordResponse.products
        .map((offProduct) => MealEntity.fromOFFProduct(offProduct))
        .toList();

    return products;
  }

  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    final productResponse = await _offDataSource.fetchBarcodeResults(barcode);

    return MealEntity.fromOFFProduct(productResponse.product);
  }
}
