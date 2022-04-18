part of dashboard;

class EditModeSettings {
  const EditModeSettings(
      {this.resizeCursorSide = 10,
      this.editBackground = true,
      this.fillEditingBackground = true,
      this.backgroundStyle = const EditModeBackgroundStyle(),
      this.foregroundStyle = const EditModeForegroundStyle(),
      this.fillBackgroundAnimationCurve = Curves.easeInOut,
      this.fillBackgroundAnimationDuration =
          const Duration(milliseconds: 200)});

  final Duration fillBackgroundAnimationDuration;
  final Curve fillBackgroundAnimationCurve;
  final double resizeCursorSide;
  final bool editBackground;
  final bool fillEditingBackground;
  final EditModeBackgroundStyle backgroundStyle;
  final EditModeForegroundStyle foregroundStyle;
}
