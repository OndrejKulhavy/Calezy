import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:calezy/core/domain/entity/intake_type_entity.dart';
import 'package:calezy/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:calezy/core/presentation/widgets/image_full_screen.dart';
import 'package:calezy/core/presentation/widgets/health_indicator_widgets.dart';
import 'package:calezy/core/utils/locator.dart';
import 'package:calezy/core/utils/navigation_options.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calezy/features/add_meal/domain/entity/meal_health_entity.dart';
import 'package:calezy/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:calezy/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_detail_bottom_sheet.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_detail_macro_nutrients.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_info_button.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_placeholder.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/meal_title_expanded.dart';
import 'package:calezy/features/meal_detail/presentation/widgets/off_disclaimer.dart';
import 'package:calezy/generated/l10n.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  static const _containerSize = 350.0;

  static const String _initialQuantityMetric = '100';
  static const String _initialQuantityImperial = '1';

  final log = Logger('ItemDetailScreen');

  late MealDetailBloc _mealDetailBloc;
  final _scrollController = ScrollController();

  late MealEntity meal;
  late DateTime _day;
  late IntakeTypeEntity intakeTypeEntity;

  final quantityTextController = TextEditingController();
  late bool _usesImperialUnits;

  String _initialUnit = "";
  String _initialQuantity = "";

  @override
  void initState() {
    _mealDetailBloc = locator<MealDetailBloc>();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as MealDetailScreenArguments;
    meal = args.mealEntity;
    _day = args.day;
    intakeTypeEntity = args.intakeTypeEntity;
    _usesImperialUnits = args.usesImperialUnits;

    // Set initial unit
    if (_initialUnit == "") {
      if (meal.hasServingValues) {
        _initialUnit = UnitDropdownItem.serving.toString();
      } else if (meal.isLiquid) {
        _initialUnit = _usesImperialUnits
            ? UnitDropdownItem.flOz.toString()
            : UnitDropdownItem.ml.toString();
      } else if (meal.isSolid) {
        _initialUnit = _usesImperialUnits
            ? UnitDropdownItem.oz.toString()

            : UnitDropdownItem.g.toString();
      } else {
        _initialUnit = UnitDropdownItem.gml.toString();
      }
      _mealDetailBloc
          .add(UpdateKcalEvent(meal: meal, selectedUnit: _initialUnit));
    }

    // Set initial quantity
    if (_initialQuantity == "") {
      if (meal.hasServingValues) {
        _initialQuantity = "1";
        quantityTextController.text = "1";
      } else if (_usesImperialUnits) {
        _initialQuantity = _initialQuantityImperial;
        quantityTextController.text = _initialQuantityImperial;
      } else {
        _initialQuantity = _initialQuantityMetric;
        quantityTextController.text = _initialQuantityMetric;
      }
      _mealDetailBloc.add(UpdateKcalEvent(
          meal: meal, totalQuantity: quantityTextController.text));
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<MealDetailBloc, MealDetailState>(
        bloc: _mealDetailBloc,
        builder: (context, state) {
          if (state is MealDetailInitial) {
            return Scaffold(
              body: _getLoadedContent(
                context,
                state.totalQuantityConverted,
                state.totalKcal,
                state.totalCarbs,
                state.totalFat,
                state.totalProtein,
                state.selectedUnit,
              ),
              bottomSheet: MealDetailBottomSheet(
                product: meal,
                day: _day,
                intakeTypeEntity: intakeTypeEntity,
                selectedUnit: state.selectedUnit,
                mealDetailBloc: _mealDetailBloc,
                quantityTextController: quantityTextController,
                onQuantityOrUnitChanged: onQuantityOrUnitChanged,
              ),
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      String totalQuantity,
      double totalKcal,
      double totalCarbs,
      double totalFat,
      double totalProtein,
      String selectedUnit) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 180,
          flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            final top = constraints.biggest.height;
            final barsHeight =
                MediaQuery.of(context).padding.top + kToolbarHeight;
            const offset = 10;
            return FlexibleSpaceBar(
                expandedTitleScale: 1, // don't scale title
                background: MealTitleExpanded(
                    meal: meal, usesImperialUnits: _usesImperialUnits),
                title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(meal.name ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis)
                            : const SizedBox()));
          }),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(NavigationOptions.editMealRoute,
                          arguments: EditMealScreenArguments(
                            _day,
                            meal,
                            intakeTypeEntity,
                            _usesImperialUnits,
                          ));
                },
                icon: const Icon(Icons.edit_outlined))
          ],
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          const SizedBox(height: 20),
          
          // Image and Basic Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image - Much smaller and better proportioned
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        NavigationOptions.imageFullScreenRoute,
                        arguments: ImageFullScreenArguments(meal.mainImageUrl ?? ""));
                  },
                  child: Hero(
                    tag: ImageFullScreen.fullScreenHeroTag,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          cacheManager: locator<CacheManager>(),
                          imageUrl: meal.mainImageUrl ?? "",
                          fit: BoxFit.cover,
                          placeholder: (context, string) => const MealPlaceholder(),
                          errorWidget: (context, url, error) => const MealPlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Nutrition Summary - Side by side with image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calories per serving
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                        child: Column(
                          children: [
                            Text(
                              '${totalKcal.toInt()}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              S.of(context).kcalLabel,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Per serving info
                      Row(
                        children: [
                          Text(
                            'per ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          Expanded(
                            child: MealValueUnitText(
                              value: double.parse(totalQuantity),
                              meal: meal,
                              displayUnit: selectedUnit == UnitDropdownItem.serving.toString()
                                  ? meal.servingUnit
                                  : selectedUnit,
                              usesImperialUnits: _usesImperialUnits,
                              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              prefix: '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Macronutrients Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MealDetailMacroNutrients(
                    typeString: S.of(context).carbsLabel,
                    value: totalCarbs),
                MealDetailMacroNutrients(
                    typeString: S.of(context).fatLabel, 
                    value: totalFat),
                MealDetailMacroNutrients(
                    typeString: S.of(context).proteinLabel,
                    value: totalProtein)
              ],
            ),
          ),
          
          const SizedBox(height: 24),
                
                // Health Information Section - Only show if there's actual data
                _buildHealthSection(context),
                
                // Nutritional Information Table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MealDetailNutrimentsTable(
                      product: meal,
                      usesImperialUnits: _usesImperialUnits,
                      servingQuantity: meal.servingQuantity,
                      servingUnit: meal.servingUnit),
                ),
                const SizedBox(height: 32.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MealInfoButton(url: meal.url, source: meal.source),
                ),
                meal.source == MealSourceEntity.off
                    ? const Column(
                        children: [
                          SizedBox(height: 32),
                          OffDisclaimer(),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 200.0) // height added to scroll
        ]))
      ],
    );
  }

  void onQuantityOrUnitChanged(String? quantityString, String? unit) {
    if (quantityString == null || unit == null) {
      return;
    }
    _mealDetailBloc.add(UpdateKcalEvent(
        meal: meal, totalQuantity: quantityString, selectedUnit: unit));
    _scrollToCalorieText();
  }

  void _scrollToCalorieText() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _containerSize - 50,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildHealthSection(BuildContext context) {
    // Only show health section if there's actual meaningful data
    final hasHealthData = meal.health.shouldShowWarning || 
                         meal.health.nutriScore != null || 
                         meal.health.ecoScore != null ||
                         (meal.health.novaGroup != null && meal.health.novaGroup != 0);
    
    if (!hasHealthData) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Compact Health Scores in a card
          if (meal.health.nutriScore != null || 
              meal.health.ecoScore != null ||
              meal.health.novaGroup != null) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: HealthScoreIndicator(health: meal.health),
            ),
          ],
          
          // Warning Messages - More compact
          if (meal.health.shouldShowWarning) ...[
            const SizedBox(height: 12.0),
            _buildCompactHealthWarnings(context, meal.health),
          ],
          
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildCompactHealthWarnings(BuildContext context, MealHealthEntity health) {
    return Column(
      children: [
        if (health.processingLevel == ProcessingLevel.ultraProcessed)
          _buildCompactWarningCard(
            context,
            icon: Icons.warning_rounded,
            color: Colors.orange.shade600,
            title: 'Ultra-Processed',
            description: 'Heavily processed with many additives',
          ),
        
        if (health.hasRiskyAdditives) ...[
          const SizedBox(height: 8.0),
          _buildCompactWarningCard(
            context,
            icon: Icons.science_outlined,
            color: Colors.red.shade600,
            title: 'Contains Additives',
            description: 'May contain additives to avoid',
          ),
        ],
        
        if (health.nutritionalQuality == NutritionalQuality.veryPoor) ...[
          const SizedBox(height: 8.0),
          _buildCompactWarningCard(
            context,
            icon: Icons.local_dining,
            color: Colors.red.shade600,
            title: 'Poor Nutrition',
            description: 'Low nutritional score (Nutri-Score E)',
          ),
        ],
      ],
    );
  }

  Widget _buildCompactWarningCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class MealDetailScreenArguments {
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final DateTime day;
  final bool usesImperialUnits;

  MealDetailScreenArguments(
      this.mealEntity, this.intakeTypeEntity, this.day, this.usesImperialUnits);
}
