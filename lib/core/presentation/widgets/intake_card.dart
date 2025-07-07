import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:calezy/core/domain/entity/intake_entity.dart';
import 'package:calezy/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:calezy/core/presentation/widgets/health_indicator_widgets.dart';
import 'package:calezy/core/utils/locator.dart';

class IntakeCard extends StatelessWidget {
  final IntakeEntity intake;
  final Function(BuildContext, IntakeEntity)? onItemLongPressed;
  final Function(BuildContext, IntakeEntity, bool)? onItemTapped;
  final bool firstListElement;
  final bool usesImperialUnits;

  const IntakeCard(
      {required super.key,
      required this.intake,
      this.onItemLongPressed,
      this.onItemTapped,
      required this.firstListElement,
      required this.usesImperialUnits});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: firstListElement ? 16 : 0),          SizedBox(
          width: 120,
          height: 120,
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 2,
            child: InkWell(
              onLongPress: onItemLongPressed != null
                  ? () => onLongPressedItem(context)
                  : null,
              onTap: onItemTapped != null
                  ? () => onTappedItem(context, usesImperialUnits)
                  : null,
              child: Stack(
                children: [
                  // Background Image or Placeholder
                  intake.meal.mainImageUrl != null
                      ? CachedNetworkImage(
                          cacheManager: locator<CacheManager>(),
                          imageUrl: intake.meal.mainImageUrl ?? "",
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )),
                          ),
                          placeholder: (context, url) => Center(
                            child: Icon(Icons.restaurant_outlined,
                                color: Theme.of(context).colorScheme.secondary)),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(Icons.restaurant_outlined,
                                color: Theme.of(context).colorScheme.secondary)),
                        )
                      : Center(
                          child: Icon(Icons.restaurant_outlined,
                              color: Theme.of(context).colorScheme.secondary)),
                  
                  // Gradient Overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Health Warning Indicator
                  if (intake.meal.health.shouldShowWarning)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: HealthIndicatorChip(
                        health: intake.meal.health,
                        showLabel: false,
                        size: 16,
                      ),
                    ),
                  
                  // Calorie Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${intake.totalKcal.toInt()} kcal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  
                  // Product Information at Bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              intake.meal.name ?? "?",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withOpacity(0.8),
                                        ),
                                      ]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 10,
                            ),
                            const SizedBox(height: 2),
                            MealValueUnitText(
                              value: intake.amount,
                              meal: intake.meal,
                              usesImperialUnits: usesImperialUnits,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withOpacity(0.8),
                                        ),
                                      ]),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onLongPressedItem(BuildContext context) {
    onItemLongPressed?.call(context, intake);
  }

  void onTappedItem(BuildContext context, bool usesImperialUnits) {
    onItemTapped?.call(context, intake, usesImperialUnits);
  }
}
