import 'package:flutter/material.dart';
import 'package:tracksu_ui/src/theme/tokens.dart';

/// The host registers the heading font. No network fonts or app dependencies.
abstract final class TracksuTheme {
  static ThemeData dark({String headingFontFamily = 'Exo 2'}) =>
      _build(Brightness.dark, headingFontFamily);

  static ThemeData light({String headingFontFamily = 'Exo 2'}) =>
      _build(Brightness.light, headingFontFamily);

  static ThemeData _build(Brightness brightness, String headingFontFamily) {
    final bool dark = brightness == Brightness.dark;
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFAD366D),
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFFF28BB7) : const Color(0xFFA32960),
          onPrimary: dark ? const Color(0xFF3E0924) : const Color(0xFFFFFFFF),
          primaryContainer: dark
              ? const Color(0xFF51243C)
              : const Color(0xFFFFD9E6),
          onPrimaryContainer: dark
              ? const Color(0xFFFFD9E6)
              : const Color(0xFF45112B),
          secondary: dark ? const Color(0xFFC6B5E0) : const Color(0xFF655079),
          onSecondary: dark ? const Color(0xFF30213E) : const Color(0xFFFFFFFF),
          secondaryContainer: dark
              ? const Color(0xFF352D45)
              : const Color(0xFFECE2F5),
          onSecondaryContainer: dark
              ? const Color(0xFFECE2F5)
              : const Color(0xFF30213E),
          tertiary: dark ? const Color(0xFFE3C27B) : const Color(0xFF76571B),
          onTertiary: dark ? const Color(0xFF392A0B) : const Color(0xFFFFFFFF),
          surface: dark ? const Color(0xFF19161E) : const Color(0xFFFCF8FB),
          surfaceDim: dark ? const Color(0xFF19161E) : const Color(0xFFE5DEE5),
          surfaceBright: dark
              ? const Color(0xFF403A46)
              : const Color(0xFFFCF8FB),
          surfaceContainerLowest: dark
              ? const Color(0xFF131116)
              : const Color(0xFFFFFFFF),
          surfaceContainerLow: dark
              ? const Color(0xFF211D27)
              : const Color(0xFFF6F0F6),
          surfaceContainer: dark
              ? const Color(0xFF292430)
              : const Color(0xFFF0EAF1),
          surfaceContainerHigh: dark
              ? const Color(0xFF332D3B)
              : const Color(0xFFEAE3EC),
          surfaceContainerHighest: dark
              ? const Color(0xFF3D3545)
              : const Color(0xFFE3DBE6),
          onSurface: dark ? const Color(0xFFF1EAF2) : const Color(0xFF251F2B),
          onSurfaceVariant: dark
              ? const Color(0xFFC7BBCD)
              : const Color(0xFF65576C),
          outline: dark ? const Color(0xFF95879F) : const Color(0xFF82718A),
          outlineVariant: dark
              ? const Color(0xFF4D4158)
              : const Color(0xFFD3C7DB),
        );
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: brightness,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    TextStyle heading(double size) => TextStyle(
      fontFamily: headingFontFamily,
      fontSize: size,
      height: 1.2,
      fontWeight: FontWeight.w600,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final TextTheme text = base.textTheme.copyWith(
      displayLarge: heading(40),
      displayMedium: heading(36),
      displaySmall: heading(32),
      headlineLarge: heading(28),
      headlineMedium: heading(24),
      headlineSmall: heading(22),
      titleLarge: heading(20),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
    final RoundedRectangleBorder control = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UiShape.control),
    );
    final ButtonStyle button = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(UiShape.minTarget, UiShape.minTarget),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(control),
      textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
    );
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(UiShape.control),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: colors.surface,
      extensions: <ThemeExtension<dynamic>>[
        UiStatusColors(
          success: dark ? const Color(0xFF193C34) : const Color(0xFFD8F2E6),
          onSuccess: dark ? const Color(0xFFA4DECA) : const Color(0xFF164E3A),
          warning: dark ? const Color(0xFF443719) : const Color(0xFFFFEDC1),
          onWarning: dark ? const Color(0xFFF1D493) : const Color(0xFF644810),
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiShape.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: button),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: button.copyWith(
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: button),
      textButtonTheme: TextButtonThemeData(style: button),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll<Size>(
            Size(UiShape.minTarget, UiShape.minTarget),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.all(UiSpace.lg),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.onSurfaceVariant,
        indicatorColor: colors.primary,
        dividerColor: colors.outlineVariant,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLow,
        indicatorColor: colors.primaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerLow,
        selectedColor: colors.secondaryContainer,
        side: BorderSide(color: colors.outlineVariant),
        shape: control,
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: UiSpace.sm,
          vertical: UiSpace.xs,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(style: button),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: UiSpace.xl,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        shape: control,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        modalBackgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UiShape.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiShape.sheet),
        ),
        titleTextStyle: text.titleLarge?.copyWith(color: colors.onSurface),
        contentTextStyle: text.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        elevation: 0,
        shape: control,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: control,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      // Keep Flutter's platform-adaptive route transitions and control states.
    );
  }
}
