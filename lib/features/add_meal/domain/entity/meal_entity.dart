import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:calezy/core/data/dbo/meal_dbo.dart';
import 'package:calezy/core/utils/id_generator.dart';
import 'package:calezy/core/utils/supported_language.dart';
import 'package:calezy/features/add_meal/data/dto/off/off_product_dto.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class MealEntity extends Equatable {
  static const liquidUnits = {'ml', 'l', 'dl', 'cl', 'fl oz', 'fl.oz'};
  static const solidUnits = {
    'kg',
    'g',
    'mg',
    'µg',
    'oz',
  };

  final String? code;
  final String? name;

  final String? brands;

  final String? thumbnailImageUrl;
  final String? mainImageUrl;

  final String? url;

  final String? mealQuantity;
  final String? mealUnit;
  final double? servingQuantity;
  final String? servingUnit;
  final String? servingSize;

  get hasServingValues => servingQuantity != null && servingUnit != null;

  final MealSourceEntity source;

  final MealNutrimentsEntity nutriments;

  bool get isLiquid => liquidUnits.contains(mealUnit);

  bool get isSolid => solidUnits.contains(mealUnit);

  const MealEntity(
      {required this.code,
      required this.name,
      this.brands,
      this.thumbnailImageUrl,
      this.mainImageUrl,
      required this.url,
      required this.mealQuantity,
      required this.mealUnit,
      required this.servingQuantity,
      required this.servingUnit,
      required this.servingSize,
      required this.nutriments,
      required this.source});

  factory MealEntity.empty() => MealEntity(
      code: IdGenerator.getUniqueID(),
      name: null,
      url: null,
      mealQuantity: null,
      mealUnit: 'gml',
      servingQuantity: null,
      servingUnit: 'gml',
      servingSize: '',
      nutriments: MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom);

  factory MealEntity.fromMealDBO(MealDBO mealDBO) => MealEntity(
      code: mealDBO.code,
      name: mealDBO.name,
      brands: mealDBO.brands,
      thumbnailImageUrl: mealDBO.thumbnailImageUrl,
      mainImageUrl: mealDBO.mainImageUrl,
      url: mealDBO.url,
      mealQuantity: mealDBO.mealQuantity,
      mealUnit: mealDBO.mealUnit,
      servingQuantity: mealDBO.servingQuantity,
      servingUnit: mealDBO.servingUnit,
      servingSize: mealDBO.servingSize,
      nutriments:
          MealNutrimentsEntity.fromMealNutrimentsDBO(mealDBO.nutriments),
      source: MealSourceEntity.fromMealSourceDBO(mealDBO.source));

  factory MealEntity.fromOFFProduct(OFFProductDTO offProduct) {
    return MealEntity(
        code: offProduct.code,
        name: offProduct
            .getLocaleName(SupportedLanguage.fromCode(Platform.localeName)),
        brands: offProduct.brands,
        thumbnailImageUrl: offProduct.image_front_thumb_url,
        mainImageUrl: offProduct.image_front_url,
        url: offProduct.url,
        mealQuantity: offProduct.product_quantity?.toString(),
        mealUnit: _tryGetUnit(offProduct.quantity),
        servingQuantity: _tryQuantityCast(offProduct.serving_quantity),
        servingUnit: _tryGetUnit(offProduct.quantity),
        servingSize: offProduct.serving_size,
        nutriments:
            MealNutrimentsEntity.fromOffNutriments(offProduct.nutriments),
        source: MealSourceEntity.off);
  }

  /// Value returned from OFF can either be String, int or double.
  /// Try casting it to a double value for calculation
  static double? _tryQuantityCast(dynamic value) {
    double? parsedValue;

    if (value == null) {
      parsedValue = null;
    } else if (value is double) {
      parsedValue = value;
    } else if (value is int) {
      parsedValue = value.toDouble();
    } else if (value is String) {
      value.replaceAll(RegExp("mg|g|kg|ml|cl|l| "), ""); // TODO extract
      final doubleParsed =
          double.tryParse(value) ?? int.tryParse(value)?.toDouble();
      parsedValue = doubleParsed;
    }
    return parsedValue;
  }

  /// TODO extract correct unit
  /// Unit can either be 100g or 100ml
  static String? _tryGetUnit(String? quantityString) {
    if (quantityString == null) return null;

    final isLiter = quantityString.toUpperCase().contains("L");

    if (isLiter) {
      return "ml";
    } else {
      return "g";
    }
  }

  @override
  List<Object?> get props => [code, name];
}

enum MealSourceEntity {
  unknown,
  custom,
  off;

  factory MealSourceEntity.fromMealSourceDBO(MealSourceDBO mealSourceDBO) {
    MealSourceEntity mealSourceEntity;
    switch (mealSourceDBO) {
      case MealSourceDBO.unknown:
        mealSourceEntity = MealSourceEntity.unknown;
        break;
      case MealSourceDBO.custom:
        mealSourceEntity = MealSourceEntity.custom;
        break;
      case MealSourceDBO.off:
        mealSourceEntity = MealSourceEntity.off;
        break;
      case MealSourceDBO.fdc:
        mealSourceEntity = MealSourceEntity.unknown; // Map FDC to unknown since we're removing it
        break;
    }
    return mealSourceEntity;
  }
}
