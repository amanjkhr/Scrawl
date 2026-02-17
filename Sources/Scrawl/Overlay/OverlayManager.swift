import SwiftUI

/// Manages overlay mode activation/deactivation.
final class OverlayManager: ObservableObject {
    private var controller: OverlayWindowController?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        self.controller = OverlayWindowController(appState: appState)
    }

    func toggle() {
        controller?.toggleOverlay()
    }

    func activate() {
        controller?.showOverlay()
    }

    func deactivate() {
        controller?.hideOverlay()
    }
}
