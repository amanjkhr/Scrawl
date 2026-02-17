import SwiftUI

/// A single page of the whiteboard, containing multiple drawing elements.
struct CanvasPage: Identifiable, Codable {
    let id: UUID
    var label: String
    var elements: [DrawingElement]
    var backgroundColor: CodableColor

    init(
        id: UUID = UUID(),
        label: String = "Page 1",
        elements: [DrawingElement] = [],
        backgroundColor: CodableColor = .white
    ) {
        self.id = id
        self.label = label
        self.elements = elements
        self.backgroundColor = backgroundColor
    }

    /// Remove the last element (for undo).
    mutating func removeLastElement() {
        guard !elements.isEmpty else { return }
        elements.removeLast()
    }

    /// Clear all elements.
    mutating func clearAll() {
        elements.removeAll()
    }
}

/// Document model containing all pages.
struct ScrawlDocument: Codable {
    var pages: [CanvasPage]
    var currentPageIndex: Int
    var createdAt: Date
    var modifiedAt: Date

    init(pages: [CanvasPage] = [CanvasPage()], currentPageIndex: Int = 0) {
        self.pages = pages
        self.currentPageIndex = currentPageIndex
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}
