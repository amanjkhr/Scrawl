import AppKit
import SwiftUI

/// Controller for the transparent fullscreen overlay window.
final class OverlayWindowController: NSObject {
    private var overlayWindow: NSWindow?
    private var canvasView: DrawingCanvasView?
    private weak var appState: AppState?
    private var hiddenWindows: [NSWindow] = []

    init(appState: AppState) {
        self.appState = appState
        super.init()
    }

    /// Show the overlay window covering the entire screen.
    func showOverlay() {
        guard overlayWindow == nil else { return }
        guard let screen = NSScreen.main else { return }

        // Hide other windows to prevent them from appearing over slides
        hiddenWindows.removeAll()
        for activeWindow in NSApp.windows where activeWindow.isVisible {
            hiddenWindows.append(activeWindow)
            activeWindow.orderOut(nil)
        }

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

        if let appState = appState {
            let overlayContentView = OverlayContentView(appState: appState)
            let hostingView = NSHostingView(rootView: overlayContentView)
            hostingView.frame = screen.frame
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = .clear

            window.contentView = hostingView
        }
        appState?.isOverlayActive = true
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
    }

    /// Hide and release the overlay window.
    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        canvasView = nil
        appState?.isOverlayActive = false

        // Restore previously hidden windows
        for activeWindow in hiddenWindows {
            activeWindow.makeKeyAndOrderFront(nil)
        }
        hiddenWindows.removeAll()
    }

    /// Toggle overlay on/off.
    func toggleOverlay() {
        if overlayWindow != nil {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
}
