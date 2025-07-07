import 'package:flutter/material.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_health_entity.dart';

class HealthIndicatorChip extends StatelessWidget {
  final MealHealthEntity health;
  final bool showLabel;
  final double size;

  const HealthIndicatorChip({
    super.key,
    required this.health,
    this.showLabel = true,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!health.shouldShowWarning && health.processingLevel == ProcessingLevel.unknown) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4.0,
      children: [
        if (health.nutriScore != null)
          _buildNutriScoreChip(context),
        if (health.processingLevel == ProcessingLevel.ultraProcessed)
          _buildProcessingWarningChip(context),
        if (health.hasRiskyAdditives)
          _buildAdditivesWarningChip(context),
      ],
    );
  }

  Widget _buildNutriScoreChip(BuildContext context) {
    final color = health.nutritionalQuality.getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_dining,
            size: size,
            color: Colors.white,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4.0),
            Text(
              health.nutriScore!,
              style: TextStyle(
                color: Colors.white,
                fontSize: size - 1,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessingWarningChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade600.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: size,
            color: Colors.white,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4.0),
            Text(
              'Ultra-Processed',
              style: TextStyle(
                color: Colors.white,
                fontSize: size - 4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditivesWarningChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade600.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: size,
            color: Colors.white,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4.0),
            Text(
              'Additives',
              style: TextStyle(
                color: Colors.white,
                fontSize: size - 4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HealthScoreIndicator extends StatelessWidget {
  final MealHealthEntity health;

  const HealthScoreIndicator({
    super.key,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: [
        if (health.nutriScore != null)
          _buildScoreRow(
            'Nutrition',
            health.nutriScore!,
            health.nutritionalQuality.getColor(),
            Icons.local_dining,
          ),
        if (health.ecoScore != null)
          _buildScoreRow(
            'Environment',
            health.ecoScore!,
            health.environmentalImpact.getColor(),
            Icons.eco,
          ),
        if (health.novaGroup != null)
          _buildProcessingRow(),
      ],
    );
  }

  Widget _buildScoreRow(String label, String score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4.0),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              score,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingRow() {
    final level = health.processingLevel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: level.getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: level.getColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings, size: 14, color: level.getColor()),
          const SizedBox(width: 4.0),
          Text(
            'Processing: ',
            style: TextStyle(
              fontSize: 11,
              color: level.getColor().withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: level.getColor(),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: level.getColor().withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              health.novaGroup.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
