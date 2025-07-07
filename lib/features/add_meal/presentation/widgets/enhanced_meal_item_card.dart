import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:calezy/core/presentation/widgets/health_indicator_widgets.dart';
import 'package:calezy/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:calezy/core/utils/locator.dart';
import 'package:calezy/core/utils/navigation_options.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calezy/features/add_meal/presentation/add_meal_type.dart';
import 'package:calezy/features/meal_detail/meal_detail_screen.dart';

class EnhancedMealItemCard extends StatelessWidget {
  final MealEntity mealEntity;
  final DateTime day;
  final AddMealType addMealType;
  final bool usesImperialUnits;

  const EnhancedMealItemCard({
    super.key,
    required this.mealEntity,
    required this.day,
    required this.addMealType,
    required this.usesImperialUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onItemPressed(context),
        child: Container(
          height: 120,
          child: Row(
            children: [
              // Product Image Section
              _buildImageSection(context),
              
              // Product Details Section
              Expanded(
                child: _buildDetailsSection(context),
              ),
              
              // Action Button Section
              _buildActionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      child: Stack(
        children: [
          // Product Image
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: mealEntity.thumbnailImageUrl != null
                ? CachedNetworkImage(
                    cacheManager: locator<CacheManager>(),
                    imageUrl: mealEntity.thumbnailImageUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(context),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(context),
                  )
                : _buildImagePlaceholder(context),
          ),
          
          // Health Warning Overlay
          if (mealEntity.health.shouldShowWarning)
            Positioned(
              top: 6,
              left: 6,
              child: HealthIndicatorChip(
                health: mealEntity.health,
                showLabel: false,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText.rich(
                  TextSpan(
                    text: mealEntity.name ?? "Unknown Product",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      if (mealEntity.brands != null && mealEntity.brands!.isNotEmpty)
                        TextSpan(
                          text: ' • ${mealEntity.brands}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  minFontSize: 12,
                ),
                
                const SizedBox(height: 4),
                
                // Quantity and Health Scores
                Row(
                  children: [
                    if (mealEntity.mealQuantity != null)
                      Expanded(
                        child: MealValueUnitText(
                          value: double.tryParse(mealEntity.mealQuantity ?? '') ?? 0,
                          meal: mealEntity,
                          usesImperialUnits: usesImperialUnits,
                          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                          prefix: '',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Health Indicators Row
          HealthScoreIndicator(health: mealEntity.health),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Container(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _onItemPressed(context),
            icon: Icon(
              Icons.add_circle,
              size: 32,
            ),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemPressed(BuildContext context) {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealDetailRoute,
      arguments: MealDetailScreenArguments(
        mealEntity,
        addMealType.getIntakeType(),
        day,
        usesImperialUnits,
      ),
    );
  }
}
