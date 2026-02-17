import SwiftUI

// MARK: - Point with pressure

/// A single point in a stroke with optional pressure data.
struct StrokePoint: Codable, Equatable {
    var x: Double
    var y: Double
    var pressure: Double

    init(_ point: CGPoint, pressure: Double = 1.0) {
        self.x = point.x
        self.y = point.y
        self.pressure = pressure
    }

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

// MARK: - Shape Type

enum ShapeType: String, Codable, CaseIterable {
    case line
    case rectangle
    case ellipse
    case arrow
}

// MARK: - Drawing Element

/// A single drawable element on the canvas.
enum DrawingElement: Identifiable, Codable {
    case stroke(StrokeData)
    case shape(ShapeData)
    case text(TextData)

    var id: UUID {
        switch self {
        case .stroke(let d): return d.id
        case .shape(let d): return d.id
        case .text(let d): return d.id
        }
    }

    /// Bounding rect of the element.
    var boundingRect: CGRect {
        switch self {
        case .stroke(let d):
            return d.boundingRect
        case .shape(let d):
            return d.boundingRect
        case .text(let d):
            return d.boundingRect
        }
    }
}

// MARK: - Stroke Data

struct StrokeData: Identifiable, Codable {
    let id: UUID
    var points: [StrokePoint]
    var color: CodableColor
    var lineWidth: Double
    var opacity: Double
    var isHighlighter: Bool

    init(
        id: UUID = UUID(),
        points: [StrokePoint] = [],
        color: CodableColor = .init(.white),
        lineWidth: Double = 3.0,
        opacity: Double = 1.0,
        isHighlighter: Bool = false
    ) {
        self.id = id
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.opacity = opacity
        self.isHighlighter = isHighlighter
    }

    var boundingRect: CGRect {
        guard !points.isEmpty else { return .zero }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let minX = xs.min()!
        let minY = ys.min()!
        let maxX = xs.max()!
        let maxY = ys.max()!
        let pad = lineWidth / 2
        return CGRect(
            x: minX - pad, y: minY - pad,
            width: maxX - minX + lineWidth,
            height: maxY - minY + lineWidth
        )
    }
}

// MARK: - Shape Data

struct ShapeData: Identifiable, Codable {
    let id: UUID
    var shapeType: ShapeType
    var origin: CGPoint
    var size: CGSize
    var color: CodableColor
    var lineWidth: Double
    var isFilled: Bool

    init(
        id: UUID = UUID(),
        shapeType: ShapeType = .rectangle,
        origin: CGPoint = .zero,
        size: CGSize = .zero,
        color: CodableColor = .init(.white),
        lineWidth: Double = 3.0,
        isFilled: Bool = false
    ) {
        self.id = id
        self.shapeType = shapeType
        self.origin = origin
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
        self.isFilled = isFilled
    }

    var boundingRect: CGRect {
        CGRect(origin: origin, size: size).standardized
            .insetBy(dx: -lineWidth, dy: -lineWidth)
    }
}

// MARK: - Text Data

struct TextData: Identifiable, Codable {
    let id: UUID
    var text: String
    var position: CGPoint
    var fontSize: Double
    var color: CodableColor
    var fontName: String
    var isBold: Bool
    var isItalic: Bool

    init(
        id: UUID = UUID(),
        text: String = "",
        position: CGPoint = .zero,
        fontSize: Double = 24.0,
        color: CodableColor = .init(.white),
        fontName: String = "Helvetica Neue",
        isBold: Bool = false,
        isItalic: Bool = false
    ) {
        self.id = id
        self.text = text
        self.position = position
        self.fontSize = fontSize
        self.color = color
        self.fontName = fontName
        self.isBold = isBold
        self.isItalic = isItalic
    }

    var boundingRect: CGRect {
        let size = (text as NSString).size(
            withAttributes: [.font: nsFont]
        )
        return CGRect(origin: position, size: size)
    }

    var nsFont: NSFont {
        var traits: NSFontTraitMask = []
        if isBold { traits.insert(.boldFontMask) }
        if isItalic { traits.insert(.italicFontMask) }
        let baseFont = NSFont(name: fontName, size: fontSize)
            ?? NSFont.systemFont(ofSize: fontSize)
        if !traits.isEmpty {
            return NSFontManager.shared.convert(baseFont, toHaveTrait: traits)
        }
        return baseFont
    }
}

// MARK: - Codable Color wrapper

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(_ nsColor: NSColor) {
        let c = nsColor.usingColorSpace(.sRGB) ?? nsColor
        self.red = Double(c.redComponent)
        self.green = Double(c.greenComponent)
        self.blue = Double(c.blueComponent)
        self.alpha = Double(c.alphaComponent)
    }

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var nsColor: NSColor {
        NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    var cgColor: CGColor {
        nsColor.cgColor
    }

    var color: Color {
        Color(nsColor)
    }

    // Preset colors
    static let white = CodableColor(red: 1, green: 1, blue: 1)
    static let black = CodableColor(red: 0, green: 0, blue: 0)
    static let red = CodableColor(red: 0.92, green: 0.26, blue: 0.27)
    static let orange = CodableColor(red: 1.0, green: 0.58, blue: 0.0)
    static let yellow = CodableColor(red: 1.0, green: 0.84, blue: 0.0)
    static let green = CodableColor(red: 0.2, green: 0.78, blue: 0.35)
    static let blue = CodableColor(red: 0.0, green: 0.48, blue: 1.0)
    static let purple = CodableColor(red: 0.69, green: 0.32, blue: 0.87)
    static let cyan = CodableColor(red: 0.35, green: 0.78, blue: 0.98)
    static let pink = CodableColor(red: 1.0, green: 0.18, blue: 0.33)

    static let presets: [CodableColor] = [
        .white, .black, .red, .orange, .yellow,
        .green, .blue, .purple, .cyan, .pink
    ]
}

// CGPoint and CGSize already conform to Codable in CoreGraphics on macOS 13+
