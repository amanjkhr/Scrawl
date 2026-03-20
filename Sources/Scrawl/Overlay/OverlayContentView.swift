import SwiftUI

struct OverlayContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            // Transparent Canvas Representable
            DrawingCanvasRepresentable(appState: appState)
                .clipShape(RoundedRectangle(cornerRadius: 0))

            // Text editor overlay
            TextEditorOverlay(appState: appState)

            // Floating toolbar
            VStack {
                Spacer()
                HStack {
                    ToolbarView(appState: appState)
                        .padding(.leading, 12)
                        .padding(.bottom, 20)
                    Spacer()
                }
            }

            // Color picker popover
            if appState.showColorPicker {
                VStack {
                    Spacer()
                    HStack {
                        ColorPickerView(appState: appState)
                            .padding(.leading, 68)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.3), value: appState.showColorPicker)
    }
}
