import 'package:flutter/material.dart';
import 'package:calezy/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_entity.dart';

class MealTitleExpanded extends StatelessWidget {
  final MealEntity meal;
  final bool usesImperialUnits;

  const MealTitleExpanded(
      {super.key, required this.meal, required this.usesImperialUnits});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              meal.name ?? '',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (meal.brands != null && meal.brands!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meal.brands!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (meal.mealQuantity != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MealValueUnitText(
                  value: double.tryParse(meal.mealQuantity ?? '') ?? 0,
                  meal: meal,
                  usesImperialUnits: usesImperialUnits,
                  textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  prefix: '',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
