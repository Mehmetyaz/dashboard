part of dashboard;

class EditModeSettings {
  const EditModeSettings({
    this.resizeCursorSide = 10,
    this.paintBackground = true,
    this.fillEditingBackground = true,
    this.backgroundStyle = const EditModeBackgroundStyle(),
    this.foregroundStyle = const EditModeForegroundStyle(),
    this.fillBackgroundAnimationCurve = Curves.easeInOut,
    this.fillBackgroundAnimationDuration = const Duration(milliseconds: 200),
    this.paintItemForeground = true,
  });

  final Duration fillBackgroundAnimationDuration;
  final Curve fillBackgroundAnimationCurve;
  final double resizeCursorSide;
  final bool paintBackground;
  final bool fillEditingBackground;
  final bool paintItemForeground;
  final EditModeBackgroundStyle backgroundStyle;
  final EditModeForegroundStyle foregroundStyle;
}
