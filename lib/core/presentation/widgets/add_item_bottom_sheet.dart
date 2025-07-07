import 'package:flutter/material.dart';
import 'package:calezy/core/domain/entity/intake_type_entity.dart';
import 'package:calezy/core/domain/entity/user_activity_entity.dart';
import 'package:calezy/core/utils/custom_icons.dart';
import 'package:calezy/core/utils/navigation_options.dart';
import 'package:calezy/features/add_activity/presentation/add_activity_screen.dart';
import 'package:calezy/features/add_meal/presentation/add_meal_screen.dart';
import 'package:calezy/features/add_meal/presentation/add_meal_type.dart';
import 'package:calezy/features/scanner/scanner_screen.dart';
import 'package:calezy/generated/l10n.dart';

class AddItemBottomSheet extends StatelessWidget {
  final DateTime day;

  const AddItemBottomSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              S.of(context).addItemLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ListTile(
            title: Text(
              S.of(context).activityLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              S.of(context).activityExample,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            // ignore: sized_box_for_whitespace
            leading: Container(
                height: double.infinity,
                child: Icon(
                  UserActivityEntity.getIconData(),
                  color: Theme.of(context).colorScheme.onSurface,
                )),
            onTap: () {
              _showAddActivityScreen(context);
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            title: Text(
              S.of(context).breakfastLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              S.of(context).breakfastExample,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            // ignore: sized_box_for_whitespace
            leading: Container(
                height: double.infinity,
                child: Icon(IntakeTypeEntity.breakfast.getIconData())),
            trailing: IconButton(
              icon: const Icon(CustomIcons.barcode_scan),
              onPressed: () {
                _showScannerScreen(context, AddMealType.breakfastType);
              },
              tooltip: S.of(context).scanProductLabel,
            ),
            onTap: () {
              _showAddItemScreen(context, AddMealType.breakfastType);
            },
          ),
          ListTile(
            title: Text(
              S.of(context).lunchLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              S.of(context).lunchExample,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            // ignore: sized_box_for_whitespace
            leading: Container(
                height: double.infinity,
                child: Icon(IntakeTypeEntity.lunch.getIconData())),
            trailing: IconButton(
              icon: const Icon(CustomIcons.barcode_scan),
              onPressed: () {
                _showScannerScreen(context, AddMealType.lunchType);
              },
              tooltip: S.of(context).scanProductLabel,
            ),
            onTap: () {
              _showAddItemScreen(context, AddMealType.lunchType);
            },
          ),
          ListTile(
            title: Text(
              S.of(context).dinnerLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              S.of(context).dinnerExample,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            // ignore: sized_box_for_whitespace
            leading: Container(
                height: double.infinity,
                child: Icon(IntakeTypeEntity.dinner.getIconData())),
            trailing: IconButton(
              icon: const Icon(CustomIcons.barcode_scan),
              onPressed: () {
                _showScannerScreen(context, AddMealType.dinnerType);
              },
              tooltip: S.of(context).scanProductLabel,
            ),
            onTap: () {
              _showAddItemScreen(context, AddMealType.dinnerType);
            },
          ),
          ListTile(
            title: Text(
              S.of(context).snackLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              S.of(context).snackExample,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            // ignore: sized_box_for_whitespace
            leading: Container(
                height: double.infinity,
                child: Icon(IntakeTypeEntity.snack.getIconData())),
            trailing: IconButton(
              icon: const Icon(CustomIcons.barcode_scan),
              onPressed: () {
                _showScannerScreen(context, AddMealType.snackType);
              },
              tooltip: S.of(context).scanProductLabel,
            ),
            onTap: () {
              _showAddItemScreen(context, AddMealType.snackType);
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemScreen(BuildContext context, AddMealType itemType) {
    Navigator.of(context).pop(); // Close bottom sheet
    Navigator.of(context).pushNamed(NavigationOptions.addMealRoute,
        arguments: AddMealScreenArguments(
          itemType,
          day,
        ));
  }

  void _showScannerScreen(BuildContext context, AddMealType itemType) {
    Navigator.of(context).pop(); // Close bottom sheet
    Navigator.of(context).pushNamed(NavigationOptions.scannerRoute,
        arguments: ScannerScreenArguments(day, itemType.getIntakeType()));
  }

  void _showAddActivityScreen(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(NavigationOptions.addActivityRoute,
        arguments: AddActivityScreenArguments(day: day));
  }
}
