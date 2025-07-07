import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MealHealthEntity extends Equatable {
  final int? novaGroup;
  final String? nutriScore;
  final String? ecoScore;
  final List<String> additives;
  final List<String> ingredientAnalysis;

  const MealHealthEntity({
    this.novaGroup,
    this.nutriScore,
    this.ecoScore,
    this.additives = const [],
    this.ingredientAnalysis = const [],
  });

  factory MealHealthEntity.empty() => const MealHealthEntity();

  factory MealHealthEntity.fromOFFData({
    int? novaGroup,
    String? nutritionGrades,
    String? ecoscoreGrade,
    List<String>? additivesTags,
    List<String>? ingredientsAnalysisTags,
  }) {
    return MealHealthEntity(
      novaGroup: novaGroup,
      nutriScore: nutritionGrades?.toUpperCase(),
      ecoScore: ecoscoreGrade?.toUpperCase(),
      additives: additivesTags ?? [],
      ingredientAnalysis: ingredientsAnalysisTags ?? [],
    );
  }

  // Processing level assessment
  ProcessingLevel get processingLevel {
    if (novaGroup == null) return ProcessingLevel.unknown;
    
    switch (novaGroup!) {
      case 1:
        return ProcessingLevel.unprocessed;
      case 2:
        return ProcessingLevel.processed;
      case 3:
        return ProcessingLevel.processed;
      case 4:
        return ProcessingLevel.ultraProcessed;
      default:
        return ProcessingLevel.unknown;
    }
  }

  // Nutritional quality assessment
  NutritionalQuality get nutritionalQuality {
    if (nutriScore == null) return NutritionalQuality.unknown;
    
    switch (nutriScore!) {
      case 'A':
        return NutritionalQuality.excellent;
      case 'B':
        return NutritionalQuality.good;
      case 'C':
        return NutritionalQuality.fair;
      case 'D':
        return NutritionalQuality.poor;
      case 'E':
        return NutritionalQuality.veryPoor;
      default:
        return NutritionalQuality.unknown;
    }
  }

  // Environmental impact assessment
  EnvironmentalImpact get environmentalImpact {
    if (ecoScore == null) return EnvironmentalImpact.unknown;
    
    switch (ecoScore!) {
      case 'A':
        return EnvironmentalImpact.veryLow;
      case 'B':
        return EnvironmentalImpact.low;
      case 'C':
        return EnvironmentalImpact.moderate;
      case 'D':
        return EnvironmentalImpact.high;
      case 'E':
        return EnvironmentalImpact.veryHigh;
      default:
        return EnvironmentalImpact.unknown;
    }
  }

  // Check if product has concerning additives
  bool get hasRiskyAdditives {
    const riskyAdditives = [
      'en:e102', // Tartrazine
      'en:e110', // Sunset Yellow
      'en:e124', // Ponceau 4R
      'en:e129', // Allura Red
      'en:e151', // Brilliant Black
      'en:e621', // MSG
      'en:e950', // Acesulfame K
      'en:e951', // Aspartame
    ];
    
    return additives.any((additive) => 
        riskyAdditives.contains(additive.toLowerCase()));
  }

  // Should show warning to user
  bool get shouldShowWarning {
    return processingLevel == ProcessingLevel.ultraProcessed ||
           nutritionalQuality == NutritionalQuality.veryPoor ||
           hasRiskyAdditives;
  }

  @override
  List<Object?> get props => [
    novaGroup,
    nutriScore,
    ecoScore,
    additives,
    ingredientAnalysis,
  ];
}

enum ProcessingLevel {
  unknown,
  unprocessed,
  processed,
  ultraProcessed;

  String getDisplayName() {
    switch (this) {
      case ProcessingLevel.unprocessed:
        return 'Minimally Processed';
      case ProcessingLevel.processed:
        return 'Processed';
      case ProcessingLevel.ultraProcessed:
        return 'Ultra-Processed';
      case ProcessingLevel.unknown:
        return 'Unknown';
    }
  }

  Color getColor() {
    switch (this) {
      case ProcessingLevel.unprocessed:
        return Colors.green;
      case ProcessingLevel.processed:
        return Colors.orange;
      case ProcessingLevel.ultraProcessed:
        return Colors.red;
      case ProcessingLevel.unknown:
        return Colors.grey;
    }
  }
}

enum NutritionalQuality {
  unknown,
  excellent,
  good,
  fair,
  poor,
  veryPoor;

  Color getColor() {
    switch (this) {
      case NutritionalQuality.excellent:
        return Colors.green;
      case NutritionalQuality.good:
        return const Color(0xFF85BB2F);
      case NutritionalQuality.fair:
        return Colors.orange;
      case NutritionalQuality.poor:
        return const Color(0xFFE67E22);
      case NutritionalQuality.veryPoor:
        return Colors.red;
      case NutritionalQuality.unknown:
        return Colors.grey;
    }
  }
}

enum EnvironmentalImpact {
  unknown,
  veryLow,
  low,
  moderate,
  high,
  veryHigh;

  Color getColor() {
    switch (this) {
      case EnvironmentalImpact.veryLow:
        return Colors.green;
      case EnvironmentalImpact.low:
        return const Color(0xFF85BB2F);
      case EnvironmentalImpact.moderate:
        return Colors.orange;
      case EnvironmentalImpact.high:
        return const Color(0xFFE67E22);
      case EnvironmentalImpact.veryHigh:
        return Colors.red;
      case EnvironmentalImpact.unknown:
        return Colors.grey;
    }
  }
}
