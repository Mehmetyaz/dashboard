part of dashboard;
class EditModeSettings {
  const EditModeSettings(
      {this.resizeCursorSide = 10,
      this.editBackground = true,
      this.backgroundStyle = const EditModeBackgroundStyle(),
      this.foregroundStyle = const EditModeForegroundStyle()});

  final double resizeCursorSide;
  final bool editBackground;
  final EditModeBackgroundStyle backgroundStyle;
  final EditModeForegroundStyle foregroundStyle;
}
