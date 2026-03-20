import SwiftUI

/// All available drawing tools in Scrawl.
enum Tool: String, CaseIterable, Identifiable {
    case pen
    case highlighter
    case eraser
    case line
    case rectangle
    case ellipse
    case arrow
    case triangle
    case star
    case diamond
    case text
    case select
    case laser

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pen: return "Pen"
        case .highlighter: return "Highlighter"
        case .eraser: return "Eraser"
        case .line: return "Line"
        case .rectangle: return "Rectangle"
        case .ellipse: return "Ellipse"
        case .arrow: return "Arrow"
        case .triangle: return "Triangle"
        case .star: return "Star"
        case .diamond: return "Diamond"
        case .text: return "Text"
        case .select: return "Select"
        case .laser: return "Laser"
        }
    }

    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .highlighter: return "highlighter"
        case .eraser: return "eraser"
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .arrow: return "arrow.up.right"
        case .triangle: return "triangle"
        case .star: return "star"
        case .diamond: return "rhombus"
        case .text: return "textformat"
        case .select: return "cursorarrow"
        case .laser: return "laser.burst"
        }
    }

    var shortcutKey: KeyEquivalent? {
        switch self {
        case .pen: return "p"
        case .highlighter: return "h"
        case .eraser: return "e"
        case .line: return "l"
        case .rectangle: return "r"
        case .ellipse: return "o"
        case .arrow: return "a"
        case .triangle: return nil
        case .star: return nil
        case .diamond: return nil
        case .text: return "t"
        case .select: return "v"
        case .laser: return nil
        }
    }

    /// Whether this tool draws strokes (freehand paths).
    var isStrokeTool: Bool {
        self == .pen || self == .highlighter
    }

    /// Whether this tool creates shapes.
    var isShapeTool: Bool {
        self == .line || self == .rectangle || self == .ellipse || self == .arrow || self == .triangle || self == .star || self == .diamond
    }

    /// Default opacity for this tool.
    var defaultOpacity: Double {
        self == .highlighter ? 0.35 : 1.0
    }
}
