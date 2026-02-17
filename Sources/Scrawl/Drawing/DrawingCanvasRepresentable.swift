import SwiftUI

/// SwiftUI wrapper for the NSView-based drawing canvas.
struct DrawingCanvasRepresentable: NSViewRepresentable {
    @ObservedObject var appState: AppState

    func makeNSView(context: Context) -> DrawingCanvasView {
        let canvas = DrawingCanvasView(frame: .zero)
        canvas.appState = appState
        canvas.onElementAdded = { element in
            appState.addElement(element)
        }
        return canvas
    }

    func updateNSView(_ nsView: DrawingCanvasView, context: Context) {
        nsView.appState = appState
        nsView.needsDisplay = true
    }
}
