import AppKit
import SwiftUI

/// Controller for the transparent fullscreen overlay window.
final class OverlayWindowController: NSObject {
    private var overlayWindow: NSWindow?
    private var canvasView: DrawingCanvasView?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        super.init()
    }

    /// Show the overlay window covering the entire screen.
    func showOverlay() {
        guard overlayWindow == nil else { return }
        guard let screen = NSScreen.main else { return }

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.01)
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = false

        // Create canvas view for overlay
        let canvas = DrawingCanvasView(frame: screen.frame)
        canvas.appState = appState

        // Overlay canvas is transparent
        canvas.wantsLayer = true
        canvas.layer?.backgroundColor = .clear

        // Override draw method behavior for overlay
        canvas.onElementAdded = { [weak self] element in
            self?.appState?.addElement(element)
        }

        window.contentView = canvas
        window.makeKeyAndOrderFront(nil)

        // Add escape key monitor
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.hideOverlay()
                return nil
            }
            return event
        }

        self.overlayWindow = window
        self.canvasView = canvas
    }

    /// Hide and release the overlay window.
    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        canvasView = nil
        appState?.isOverlayActive = false
    }

    /// Toggle overlay on/off.
    func toggleOverlay() {
        if overlayWindow != nil {
            hideOverlay()
        } else {
            showOverlay()
            appState?.isOverlayActive = true
        }
    }
}
