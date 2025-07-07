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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onItemPressed(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                ],
              ),
            ),
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
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 120,
      child: Stack(
        children: [
          // Product Image with rounded corners
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
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
          ),
          
          // Health Warning Overlay
          if (mealEntity.health.shouldShowWarning)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HealthIndicatorChip(
                  health: mealEntity.health,
                  showLabel: false,
                  size: 18,
                ),
              ),
            ),
          
          // Calorie Badge
          if (mealEntity.nutriments.energyKcal100 != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_getDisplayCalories()',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),                  const SizedBox(height: 4),
            Text(
              'No Image',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayCalories() {
    final calories = mealEntity.nutriments.energyKcal100;
    if (calories == null) return '0 kcal';
    
    final quantity = double.tryParse(mealEntity.mealQuantity ?? '100') ?? 100;
    final actualCalories = (calories * quantity / 100).round();
    
    return '$actualCalories kcal';
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Brand with improved typography
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  mealEntity.name ?? "Unknown Product",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (mealEntity.brands != null && mealEntity.brands!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    mealEntity.brands!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Quantity Information
          if (mealEntity.mealQuantity != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: MealValueUnitText(
                value: double.tryParse(mealEntity.mealQuantity ?? '') ?? 0,
                meal: mealEntity,
                usesImperialUnits: usesImperialUnits,
                textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                prefix: '',
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Health Indicators Row
          HealthScoreIndicator(health: mealEntity.health),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onItemPressed(context),
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
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
