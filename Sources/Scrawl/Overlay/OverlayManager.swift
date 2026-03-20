import SwiftUI

/// Manages overlay mode activation/deactivation.
final class OverlayManager: ObservableObject {
    private var controller: OverlayWindowController?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        self.controller = OverlayWindowController(appState: appState)
        checkAccessibility()
        setupGlobalShortcut()
    }
    
    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    private func setupGlobalShortcut() {
        GlobalHotkeyManager.shared.toggleAction = { [weak self] in
            DispatchQueue.main.async {
                self?.toggle()
            }
        }
        // 11 is 'B', 256 is cmdKey
        GlobalHotkeyManager.shared.register(keyCode: 11, carbonModifiers: 256)
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
