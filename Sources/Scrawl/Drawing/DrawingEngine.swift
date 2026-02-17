import AppKit

/// Renders drawing elements to a CGContext.
final class DrawingEngine {

    // MARK: - Render All Elements

    func render(elements: [DrawingElement], in context: CGContext, scale: CGFloat = 1.0) {
        context.saveGState()
        context.scaleBy(x: scale, y: scale)

        for element in elements {
            switch element {
            case .stroke(let strokeData):
                renderStroke(strokeData, in: context)
            case .shape(let shapeData):
                renderShape(shapeData, in: context)
            case .text(let textData):
                renderText(textData, in: context)
            }
        }

        context.restoreGState()
    }

    // MARK: - Render Stroke

    func renderStroke(_ stroke: StrokeData, in context: CGContext) {
        guard stroke.points.count >= 2 else { return }

        context.saveGState()
        context.setAlpha(stroke.opacity)
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        if stroke.isHighlighter {
            context.setBlendMode(.normal)
        }

        let path = CGMutablePath()
        let points = stroke.points

        path.move(to: points[0].cgPoint)

        if points.count == 2 {
            path.addLine(to: points[1].cgPoint)
        } else {
            // Smooth Catmull-Rom spline interpolation
            for i in 1..<points.count {
                let p0 = points[max(0, i - 2)].cgPoint
                let p1 = points[i - 1].cgPoint
                let p2 = points[i].cgPoint
                let p3 = points[min(points.count - 1, i + 1)].cgPoint

                let cp1x = p1.x + (p2.x - p0.x) / 6.0
                let cp1y = p1.y + (p2.y - p0.y) / 6.0
                let cp2x = p2.x - (p3.x - p1.x) / 6.0
                let cp2y = p2.y - (p3.y - p1.y) / 6.0

                path.addCurve(
                    to: p2,
                    control1: CGPoint(x: cp1x, y: cp1y),
                    control2: CGPoint(x: cp2x, y: cp2y)
                )
            }
        }

        context.addPath(path)
        context.strokePath()
        context.restoreGState()
    }

    // MARK: - Render Shape

    func renderShape(_ shape: ShapeData, in context: CGContext) {
        context.saveGState()
        context.setStrokeColor(shape.color.cgColor)
        context.setLineWidth(shape.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        let rect = CGRect(origin: shape.origin, size: shape.size).standardized

        switch shape.shapeType {
        case .rectangle:
            if shape.isFilled {
                context.setFillColor(shape.color.cgColor)
                context.fill(rect)
            } else {
                context.stroke(rect)
            }

        case .ellipse:
            if shape.isFilled {
                context.setFillColor(shape.color.cgColor)
                context.fillEllipse(in: rect)
            } else {
                context.strokeEllipse(in: rect)
            }

        case .line:
            context.move(to: shape.origin)
            context.addLine(to: CGPoint(
                x: shape.origin.x + shape.size.width,
                y: shape.origin.y + shape.size.height
            ))
            context.strokePath()

        case .arrow:
            let start = shape.origin
            let end = CGPoint(
                x: shape.origin.x + shape.size.width,
                y: shape.origin.y + shape.size.height
            )
            // Draw line
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()

            // Draw arrowhead
            let angle = atan2(end.y - start.y, end.x - start.x)
            let arrowLength: CGFloat = 15.0
            let arrowAngle: CGFloat = .pi / 6

            let p1 = CGPoint(
                x: end.x - arrowLength * cos(angle - arrowAngle),
                y: end.y - arrowLength * sin(angle - arrowAngle)
            )
            let p2 = CGPoint(
                x: end.x - arrowLength * cos(angle + arrowAngle),
                y: end.y - arrowLength * sin(angle + arrowAngle)
            )

            context.move(to: end)
            context.addLine(to: p1)
            context.strokePath()
            context.move(to: end)
            context.addLine(to: p2)
            context.strokePath()
        }

        context.restoreGState()
    }

    // MARK: - Render Text

    func renderText(_ textData: TextData, in context: CGContext) {
        guard !textData.text.isEmpty else { return }

        context.saveGState()

        // Flip context for text rendering (Core Graphics has flipped Y)
        let font = textData.nsFont
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textData.color.nsColor
        ]

        let attrString = NSAttributedString(string: textData.text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRangeMake(0, attrString.length),
            nil,
            CGSize(width: 1000, height: 1000),
            nil
        )

        let textRect = CGRect(origin: textData.position, size: suggestedSize)
        let path = CGPath(rect: textRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)

        context.saveGState()
        context.translateBy(x: 0, y: textRect.origin.y + textRect.height)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -textRect.origin.y)

        CTFrameDraw(frame, context)
        context.restoreGState()

        context.restoreGState()
    }

    // MARK: - Hit Testing

    func hitTest(point: CGPoint, elements: [DrawingElement], tolerance: CGFloat = 8.0) -> DrawingElement? {
        for element in elements.reversed() {
            let expandedRect = element.boundingRect.insetBy(
                dx: -tolerance, dy: -tolerance
            )
            if expandedRect.contains(point) {
                return element
            }
        }
        return nil
    }
}
