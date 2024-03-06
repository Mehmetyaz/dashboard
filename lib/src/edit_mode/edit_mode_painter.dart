part of '../dashboard_base.dart';

class _EditModeBackgroundPainter extends CustomPainter {
  _EditModeBackgroundPainter(
      {required this.offset,
      required this.slotEdge,
      required this.verticalSlotEdge,
      required this.slotCount,
      required this.viewportDelegate,
      this.fillPosition,
      required this.lines,
      this.style = const EditModeBackgroundStyle()});

  _ViewportDelegate viewportDelegate;

  final bool lines;

  Rect? fillPosition;

  double offset;

  double slotEdge, verticalSlotEdge;

  int slotCount;

  BoxConstraints get constraints => viewportDelegate.resolvedConstrains;

  double get mainAxisSpace => viewportDelegate.mainAxisSpace;

  double get crossAxisSpace => viewportDelegate.crossAxisSpace;

  EditModeBackgroundStyle style;

  void drawVerticalLines(Canvas canvas) {
    if (!lines) {
      return;
    }

    var horizontalLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth;
    var sY = -0.0 -
        (offset.clamp(0, 100)) -
        (style.dualLineHorizontal ? mainAxisSpace / 2 : 0);
    var eY = constraints.maxHeight + 100;
    for (var i in List.generate(slotCount + 1, (index) => index)) {
      if (i == 0) {
        canvas.drawLine(Offset(0, sY), Offset(0, eY), horizontalLinePaint);
      } else if (i == slotCount) {
        var x = slotEdge * slotCount;
        canvas.drawLine(Offset(x, sY), Offset(x, eY), horizontalLinePaint);
      } else {
        if (style.dualLineVertical) {
          var l = (slotEdge * i) - crossAxisSpace / 2;
          var r = (slotEdge * i) + crossAxisSpace / 2;
          canvas.drawLine(Offset(l, sY), Offset(l, eY), horizontalLinePaint);
          canvas.drawLine(Offset(r, sY), Offset(r, eY), horizontalLinePaint);
        } else {
          var x = (slotEdge * i);
          canvas.drawLine(Offset(x, sY), Offset(x, eY), horizontalLinePaint);
        }
      }
    }
  }

  void drawHorizontals(Canvas canvas) {
    if (!lines) {
      return;
    }

    var horizontalLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth;
    var max = constraints.maxHeight;
    var i = 0;
    var s = offset % verticalSlotEdge;
    while (true) {
      var y = (i * verticalSlotEdge) - s;
      if (y > max) {
        break;
      }

      if (style.dualLineHorizontal) {
        var t = y - mainAxisSpace / 2;
        var b = y + mainAxisSpace / 2;
        canvas.drawLine(
            Offset(0, t), Offset(constraints.maxWidth, t), horizontalLinePaint);
        canvas.drawLine(
            Offset(0, b), Offset(constraints.maxWidth, b), horizontalLinePaint);
      } else {
        canvas.drawLine(
            Offset(0, y), Offset(constraints.maxWidth, y), horizontalLinePaint);
      }

      i++;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawVerticalLines(canvas);
    drawHorizontals(canvas);
    if (fillPosition != null) {
      var path = Path()
        ..moveTo(fillPosition!.left + style.outherRadius, fillPosition!.top)
        ..lineTo(fillPosition!.right - style.outherRadius, fillPosition!.top)
        ..arcToPoint(
            Offset(fillPosition!.right, fillPosition!.top + style.outherRadius),
            radius: Radius.circular(style.outherRadius))
        ..lineTo(fillPosition!.right, fillPosition!.bottom - style.outherRadius)
        ..arcToPoint(
            Offset(
                fillPosition!.right - style.outherRadius, fillPosition!.bottom),
            radius: Radius.circular(style.outherRadius))
        ..lineTo(fillPosition!.left + style.outherRadius, fillPosition!.bottom)
        ..arcToPoint(
            Offset(
                fillPosition!.left, fillPosition!.bottom - style.outherRadius),
            radius: Radius.circular(style.outherRadius))
        ..lineTo(fillPosition!.left, fillPosition!.top + style.outherRadius)
        ..arcToPoint(
            Offset(fillPosition!.left + style.outherRadius, fillPosition!.top),
            radius: Radius.circular(style.outherRadius))
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = style.fillColor,
      );
    }
  }

  @override
  bool shouldRepaint(_EditModeBackgroundPainter oldDelegate) {
    return true /*fillPosition != oldDelegate.fillPosition ||
        offset != oldDelegate.offset ||
        slotEdge != oldDelegate.slotEdge ||
        slotCount != oldDelegate.slotCount ||
        style != oldDelegate.style ||
        viewportDelegate != oldDelegate.viewportDelegate*/
        ;
  }

  @override
  bool shouldRebuildSemantics(_EditModeBackgroundPainter oldDelegate) {
    return true;
  }
}

// class _EditModeItemPainter extends CustomPainter {
//   _EditModeItemPainter(
//       {required this.style,
//       required double tolerance,
//       required this.constraints})
//       : tolerance = style.sideWidth ?? tolerance;
//
//   final EditModeForegroundStyle style;
//   final double tolerance;
//   final BoxConstraints constraints;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var outher = Path()
//       ..moveTo(style.outherRadius, 0)
//       ..lineTo(constraints.maxWidth - style.outherRadius, 0)
//       ..arcToPoint(Offset(constraints.maxWidth, style.outherRadius),
//           radius: Radius.circular(style.outherRadius))
//       ..lineTo(constraints.maxWidth, constraints.maxHeight - style.outherRadius)
//       ..arcToPoint(
//           Offset(
//               constraints.maxWidth - style.outherRadius, constraints.maxHeight),
//           radius: Radius.circular(style.outherRadius))
//       ..lineTo(style.outherRadius, constraints.maxHeight)
//       ..arcToPoint(Offset(0, constraints.maxHeight - style.outherRadius),
//           radius: Radius.circular(style.outherRadius))
//       ..lineTo(0, style.outherRadius)
//       ..arcToPoint(Offset(style.outherRadius, 0),
//           radius: Radius.circular(style.outherRadius))
//       ..close();
//
//     var inner = Path()
//       ..moveTo(style.innerRadius + tolerance, tolerance)
//       ..lineTo(constraints.maxWidth - style.innerRadius - tolerance, tolerance)
//       ..arcToPoint(
//           Offset(constraints.maxWidth, style.innerRadius)
//               .translate(-tolerance, tolerance),
//           radius: Radius.circular(style.innerRadius))
//       ..lineTo(constraints.maxWidth - tolerance,
//           constraints.maxHeight - style.innerRadius - tolerance)
//       ..arcToPoint(
//           Offset(constraints.maxWidth - style.innerRadius,
//                   constraints.maxHeight)
//               .translate(-tolerance, -tolerance),
//           radius: Radius.circular(style.innerRadius))
//       ..lineTo(style.innerRadius + tolerance, constraints.maxHeight - tolerance)
//       ..arcToPoint(
//           Offset(0, constraints.maxHeight - style.innerRadius)
//               .translate(tolerance, -tolerance),
//           radius: Radius.circular(style.innerRadius))
//       ..lineTo(tolerance, style.innerRadius + tolerance)
//       ..arcToPoint(Offset(style.innerRadius + tolerance, tolerance),
//           radius: Radius.circular(style.innerRadius))
//       ..close();
//
//     var path = Path.combine(PathOperation.difference, outher, inner);
//     canvas.drawShadow(path, style.shadowColor, style.shadowElevation,
//         style.shadowTransparentOccluder);
//     canvas.drawPath(
//       path,
//       Paint()
//         ..style = PaintingStyle.fill
//         ..color = style.fillColor,
//     );
//   }
//
//   @override
//   bool shouldRepaint(_EditModeItemPainter oldDelegate) {
//     return constraints != oldDelegate.constraints;
//   }
//
//   @override
//   bool shouldRebuildSemantics(_EditModeItemPainter oldDelegate) {
//     return constraints != oldDelegate.constraints;
//   }
// }
