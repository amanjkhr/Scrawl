import SwiftUI
import Combine

/// Global application state for Scrawl.
final class AppState: ObservableObject {
    // MARK: - Tool State
    @Published var selectedTool: Tool = .pen
    @Published var strokeColor: CodableColor = .black
    @Published var strokeWidth: Double = 3.0
    @Published var opacity: Double = 1.0
    @Published var fontSize: Double = 24.0
    @Published var isBold: Bool = false
    @Published var isItalic: Bool = false

    // MARK: - Canvas State
    @Published var pages: [CanvasPage] = [CanvasPage()]
    @Published var currentPageIndex: Int = 0
    @Published var canvasScale: CGFloat = 1.0
    @Published var canvasOffset: CGPoint = .zero

    // MARK: - Overlay State
    @Published var isOverlayActive: Bool = false

    // MARK: - Undo/Redo
    @Published var undoStack: [[DrawingElement]] = []
    @Published var redoStack: [[DrawingElement]] = []

    // MARK: - UI State
    @Published var showPageNavigator: Bool = true
    @Published var showColorPicker: Bool = false
    @Published var isEditingText: Bool = false
    @Published var editingTextId: UUID? = nil
    @Published var editingTextValue: String = ""
    @Published var editingTextPosition: CGPoint = .zero

    // MARK: - Current Page
    var currentPage: CanvasPage {
        get {
            guard pages.indices.contains(currentPageIndex) else {
                return CanvasPage()
            }
            return pages[currentPageIndex]
        }
        set {
            guard pages.indices.contains(currentPageIndex) else { return }
            pages[currentPageIndex] = newValue
        }
    }

    // MARK: - Undo / Redo

    func saveUndoState() {
        undoStack.append(currentPage.elements)
        redoStack.removeAll()
    }

    func undo() {
        guard !undoStack.isEmpty else { return }
        redoStack.append(currentPage.elements)
        currentPage.elements = undoStack.removeLast()
    }

    func redo() {
        guard !redoStack.isEmpty else { return }
        undoStack.append(currentPage.elements)
        currentPage.elements = redoStack.removeLast()
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Page Management

    func addPage() {
        let newPage = CanvasPage(
            label: "Page \(pages.count + 1)",
            backgroundColor: currentPage.backgroundColor
        )
        pages.append(newPage)
        currentPageIndex = pages.count - 1
        undoStack.removeAll()
        redoStack.removeAll()
    }

    func deletePage(at index: Int) {
        guard pages.count > 1, pages.indices.contains(index) else { return }
        pages.remove(at: index)
        if currentPageIndex >= pages.count {
            currentPageIndex = pages.count - 1
        }
        undoStack.removeAll()
        redoStack.removeAll()
    }

    func switchToPage(_ index: Int) {
        guard pages.indices.contains(index) else { return }
        currentPageIndex = index
        undoStack.removeAll()
        redoStack.removeAll()
    }

    // MARK: - Element Operations

    func addElement(_ element: DrawingElement) {
        saveUndoState()
        currentPage.elements.append(element)
    }

    func removeElement(withId id: UUID) {
        saveUndoState()
        currentPage.elements.removeAll { $0.id == id }
    }

    func clearCanvas() {
        saveUndoState()
        currentPage.clearAll()
    }

    // MARK: - Eraser

    func eraseAt(point: CGPoint, radius: Double = 10.0) {
        let eraseRect = CGRect(
            x: point.x - radius, y: point.y - radius,
            width: radius * 2, height: radius * 2
        )
        let toRemove = currentPage.elements.filter { $0.boundingRect.intersects(eraseRect) }
        if !toRemove.isEmpty {
            saveUndoState()
            let removeIds = Set(toRemove.map(\.id))
            currentPage.elements.removeAll { removeIds.contains($0.id) }
        }
    }

    // MARK: - Tool Selection Helpers

    func selectTool(_ tool: Tool) {
        selectedTool = tool
        if tool == .highlighter {
            opacity = 0.35
        } else if tool != .text {
            opacity = 1.0
        }
    }

    // MARK: - Zoom

    func zoomIn() {
        canvasScale = min(canvasScale * 1.25, 5.0)
    }

    func zoomOut() {
        canvasScale = max(canvasScale / 1.25, 0.25)
    }

    func resetZoom() {
        canvasScale = 1.0
        canvasOffset = .zero
    }
}
