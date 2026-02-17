import SwiftUI

/// Main content view composing the canvas, toolbar, and page navigator.
struct ContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Page Navigator (collapsible)
                if appState.showPageNavigator {
                    PageNavigatorView(appState: appState)
                        .transition(.move(edge: .leading))
                }

                // Canvas area
                ZStack {
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
                            Spacer()
                        }
                        Spacer()
                    }

                    // Color picker popover
                    if appState.showColorPicker {
                        VStack {
                            Spacer()
                            HStack {
                                ColorPickerView(appState: appState)
                                    .padding(.leading, 68)
                                Spacer()
                            }
                            Spacer()
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }

                    // Zoom indicator
                    if appState.canvasScale != 1.0 {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(Int(appState.canvasScale * 100))%")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule().fill(.ultraThinMaterial)
                                    )
                                    .padding(12)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.showPageNavigator)
        .animation(.spring(response: 0.3), value: appState.showColorPicker)
    }
}
