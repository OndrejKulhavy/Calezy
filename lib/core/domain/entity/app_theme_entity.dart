import 'package:flutter/material.dart';
import 'package:calezy/core/data/dbo/app_theme_dbo.dart';

enum AppThemeEntity {
  light,
  dark,
  system,
  dynamic;

  factory AppThemeEntity.fromAppThemeDBO(AppThemeDBO dbo) {
    AppThemeEntity entity;
    switch (dbo) {
      case AppThemeDBO.light:
        entity = AppThemeEntity.light;
        break;
      case AppThemeDBO.dark:
        entity = AppThemeEntity.dark;
        break;
      case AppThemeDBO.system:
        entity = AppThemeEntity.system;
        break;
      case AppThemeDBO.dynamic:
        entity = AppThemeEntity.dynamic;
        break;
      }
    return entity;
  }

  ThemeMode toThemeMode() {
    ThemeMode mode;
    switch (this) {
      case AppThemeEntity.light:
        mode = ThemeMode.light;
        break;
      case AppThemeEntity.dark:
        mode = ThemeMode.dark;
        break;
      case AppThemeEntity.system:
        mode = ThemeMode.system;
        break;
      case AppThemeEntity.dynamic:
        mode = ThemeMode.system; // Dynamic colors follow system theme
        break;
    }
    return mode;
  }
}
