part of dashboard;
class EditModeBackgroundStyle {
  const EditModeBackgroundStyle(
      {this.doubleLineVertical = true,
      this.doubleLineHorizontal = true,
      this.radius = 8,
      this.lineWidth = 0.7,
      this.lineColor = Colors.black54});

  final bool doubleLineVertical, doubleLineHorizontal;
  final double lineWidth;
  final double radius;
  final Color lineColor;
}

class EditModeForegroundStyle {
  const EditModeForegroundStyle(
      {this.fillColor = Colors.black26,
      this.innerRadius = 8,
      this.outherRadius = 8,
      this.shadowColor = Colors.white24,
      this.shadowElevation = 4,
      this.shadowTransparentOccluder = true,
      this.sideWidth});

  final double? sideWidth;
  final Color fillColor;
  final double innerRadius, outherRadius;
  final Color shadowColor;
  final bool shadowTransparentOccluder;
  final double shadowElevation;
}
