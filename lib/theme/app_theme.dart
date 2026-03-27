import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Custom Cupertino App Theme
class AppTheme {
  static CupertinoThemeData lightTheme() {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: AppColors.lightSecondaryBackground,
      barBackgroundColor: AppColors.lightBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: AppTypography.body.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        actionTextStyle: AppTypography.headline.copyWith(
          color: AppColors.primaryBlue,
        ),
        tabLabelTextStyle: AppTypography.footnote.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        navTitleTextStyle: AppTypography.headline.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        navLargeTitleTextStyle: AppTypography.largeTitle.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        pickerTextStyle: AppTypography.body.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        dateTimePickerTextStyle: AppTypography.body.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  static CupertinoThemeData darkTheme() {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlueLight,
      primaryContrastingColor: AppColors.darkBackground,
      scaffoldBackgroundColor: AppColors.darkSecondaryBackground,
      barBackgroundColor: AppColors.darkBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: AppTypography.body.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        actionTextStyle: AppTypography.headline.copyWith(
          color: AppColors.primaryBlueLight,
        ),
        tabLabelTextStyle: AppTypography.footnote.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        navTitleTextStyle: AppTypography.headline.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        navLargeTitleTextStyle: AppTypography.largeTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        pickerTextStyle: AppTypography.body.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        dateTimePickerTextStyle: AppTypography.body.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
    );
  }
}
