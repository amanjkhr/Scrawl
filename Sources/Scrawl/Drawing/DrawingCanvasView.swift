import AppKit
import SwiftUI

/// NSView-based canvas that handles all mouse/trackpad drawing interactions.
final class DrawingCanvasView: NSView {

    // MARK: - Properties

    var appState: AppState?
    var drawingEngine = DrawingEngine()
    var onElementAdded: ((DrawingElement) -> Void)?

    // In-progress drawing state
    private var currentStrokePoints: [StrokePoint] = []
    private var shapeOrigin: CGPoint = .zero
    private var currentShapePreview: ShapeData?
    private var isDragging = false

    // Laser pointer state
    private var laserPoints: [(point: CGPoint, timestamp: Date)] = []
    private var laserTimer: Timer?

    // MARK: - Setup

    override var isFlipped: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = .clear
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        guard let state = appState else { return }

        // Background
        context.setFillColor(state.currentPage.backgroundColor.cgColor)
        context.fill(bounds)

        // Draw grid (subtle)
        drawGrid(in: context)

        // Draw all committed elements
        drawingEngine.render(elements: state.currentPage.elements, in: context)

        // Draw in-progress stroke
        if !currentStrokePoints.isEmpty, let state = appState {
            let previewStroke = StrokeData(
                points: currentStrokePoints,
                color: state.strokeColor,
                lineWidth: state.strokeWidth,
                opacity: state.opacity,
                isHighlighter: state.selectedTool == .highlighter
            )
            drawingEngine.renderStroke(previewStroke, in: context)
        }

        // Draw in-progress shape preview
        if let preview = currentShapePreview {
            drawingEngine.renderShape(preview, in: context)
        }

        // Draw laser pointer
        if !laserPoints.isEmpty {
            drawLaser(in: context)
        }
    }

    private func drawGrid(in context: CGContext) {
        let gridSize: CGFloat = 40
        let gridColor = NSColor.black.withAlphaComponent(0.06).cgColor

        context.saveGState()
        context.setStrokeColor(gridColor)
        context.setLineWidth(0.5)

        var x: CGFloat = 0
        while x <= bounds.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            x += gridSize
        }

        var y: CGFloat = 0
        while y <= bounds.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
            y += gridSize
        }

        context.strokePath()
        context.restoreGState()
    }

    private func drawLaser(in context: CGContext) {
        let now = Date()
        context.saveGState()

        for (i, lp) in laserPoints.enumerated() {
            let age = now.timeIntervalSince(lp.timestamp)
            let maxAge: Double = 1.0
            let alpha = max(0, 1.0 - age / maxAge)
            let radius: CGFloat = 6.0

            // Outer glow
            context.setFillColor(NSColor.red.withAlphaComponent(alpha * 0.3).cgColor)
            context.fillEllipse(in: CGRect(
                x: lp.point.x - radius * 2, y: lp.point.y - radius * 2,
                width: radius * 4, height: radius * 4
            ))

            // Core dot
            context.setFillColor(NSColor.red.withAlphaComponent(alpha).cgColor)
            context.fillEllipse(in: CGRect(
                x: lp.point.x - radius, y: lp.point.y - radius,
                width: radius * 2, height: radius * 2
            ))

            // Trail line to next point
            if i + 1 < laserPoints.count {
                let next = laserPoints[i + 1]
                context.setStrokeColor(NSColor.red.withAlphaComponent(alpha * 0.5).cgColor)
                context.setLineWidth(3)
                context.move(to: lp.point)
                context.addLine(to: next.point)
                context.strokePath()
            }
        }

        context.restoreGState()
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        guard let state = appState else { return }
        let point = convert(event.locationInWindow, from: nil)
        isDragging = true

        switch state.selectedTool {
        case .pen, .highlighter:
            currentStrokePoints = [StrokePoint(point, pressure: Double(event.pressure))]

        case .eraser:
            state.eraseAt(point: point)
            needsDisplay = true

        case .line, .rectangle, .ellipse, .arrow:
            shapeOrigin = point
            currentShapePreview = ShapeData(
                shapeType: shapeTypeFromTool(state.selectedTool),
                origin: point,
                size: .zero,
                color: state.strokeColor,
                lineWidth: state.strokeWidth
            )

        case .text:
            state.isEditingText = true
            state.editingTextPosition = point
            state.editingTextValue = ""
            state.editingTextId = UUID()

        case .laser:
            laserPoints.removeAll()
            laserPoints.append((point: point, timestamp: Date()))
            startLaserTimer()

        case .select:
            break // TODO: selection mode
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard let state = appState, isDragging else { return }
        let point = convert(event.locationInWindow, from: nil)

        switch state.selectedTool {
        case .pen, .highlighter:
            currentStrokePoints.append(StrokePoint(point, pressure: Double(event.pressure)))
            needsDisplay = true

        case .eraser:
            state.eraseAt(point: point)
            needsDisplay = true

        case .line, .rectangle, .ellipse, .arrow:
            currentShapePreview?.size = CGSize(
                width: point.x - shapeOrigin.x,
                height: point.y - shapeOrigin.y
            )
            needsDisplay = true

        case .laser:
            laserPoints.append((point: point, timestamp: Date()))
            needsDisplay = true

        default:
            break
        }
    }

    override func mouseUp(with event: NSEvent) {
        guard let state = appState, isDragging else { return }
        isDragging = false

        switch state.selectedTool {
        case .pen, .highlighter:
            if currentStrokePoints.count >= 2 {
                let stroke = StrokeData(
                    points: currentStrokePoints,
                    color: state.strokeColor,
                    lineWidth: state.strokeWidth,
                    opacity: state.opacity,
                    isHighlighter: state.selectedTool == .highlighter
                )
                onElementAdded?(.stroke(stroke))
            }
            currentStrokePoints.removeAll()

        case .line, .rectangle, .ellipse, .arrow:
            if let preview = currentShapePreview,
               abs(preview.size.width) > 2 || abs(preview.size.height) > 2 {
                onElementAdded?(.shape(preview))
            }
            currentShapePreview = nil

        case .laser:
            // Laser fades naturally
            break

        default:
            break
        }

        needsDisplay = true
    }

    // MARK: - Keyboard Shortcuts

    override func keyDown(with event: NSEvent) {
        guard let state = appState else {
            super.keyDown(with: event)
            return
        }

        // Don't intercept shortcuts while editing text
        if state.isEditingText {
            super.keyDown(with: event)
            return
        }

        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""

        switch key {
        case "p": state.selectTool(.pen)
        case "h": state.selectTool(.highlighter)
        case "e": state.selectTool(.eraser)
        case "t": state.selectTool(.text)
        case "l": state.selectTool(.line)
        case "r": state.selectTool(.rectangle)
        case "o": state.selectTool(.ellipse)
        case "a": state.selectTool(.arrow)
        case "s": state.selectTool(.select)
        case "x": state.selectTool(.laser)
        default:
            super.keyDown(with: event)
        }
    }

    // MARK: - Scroll (Zoom)

    override func magnify(with event: NSEvent) {
        guard let state = appState else { return }
        let newScale = state.canvasScale + event.magnification
        state.canvasScale = max(0.25, min(5.0, newScale))
    }

    // MARK: - Helpers

    private func shapeTypeFromTool(_ tool: Tool) -> ShapeType {
        switch tool {
        case .line: return .line
        case .rectangle: return .rectangle
        case .ellipse: return .ellipse
        case .arrow: return .arrow
        default: return .line
        }
    }

    private func startLaserTimer() {
        laserTimer?.invalidate()
        laserTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let now = Date()
            self.laserPoints.removeAll { now.timeIntervalSince($0.timestamp) > 1.0 }
            self.needsDisplay = true
            if self.laserPoints.isEmpty {
                self.laserTimer?.invalidate()
                self.laserTimer = nil
            }
        }
    }
}
