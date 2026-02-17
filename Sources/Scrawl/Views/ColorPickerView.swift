import SwiftUI

/// Color picker popover with preset swatches and stroke controls — dark panel for contrast.
struct ColorPickerView: View {
    @ObservedObject var appState: AppState
    @State private var customColor: Color = .white

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Color & Stroke")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    appState.showColorPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            // Preset Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Colors")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(32), spacing: 6), count: 5), spacing: 6) {
                    ForEach(Array(CodableColor.presets.enumerated()), id: \.offset) { _, preset in
                        Button {
                            appState.strokeColor = preset
                        } label: {
                            Circle()
                                .fill(preset.color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            appState.strokeColor == preset
                                                ? Color.white
                                                : Color.white.opacity(0.25),
                                            lineWidth: appState.strokeColor == preset ? 2.5 : 1
                                        )
                                )
                                .scaleEffect(appState.strokeColor == preset ? 1.1 : 1.0)
                                .animation(.spring(response: 0.2), value: appState.strokeColor == preset)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Custom Color Picker
            HStack {
                Text("Custom")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                Spacer()
                ColorPicker("", selection: $customColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 30, height: 30)
                    .onChange(of: customColor) { newColor in
                        if let nsColor = NSColor(newColor).usingColorSpace(.sRGB) {
                            appState.strokeColor = CodableColor(nsColor)
                        }
                    }
            }

            Divider().background(Color.white.opacity(0.15))

            // Stroke Width
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Stroke Width")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                    Spacer()
                    Text("\(Int(appState.strokeWidth))pt")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }

                HStack(spacing: 12) {
                    // Preview dot
                    Circle()
                        .fill(appState.strokeColor.color)
                        .frame(width: appState.strokeWidth, height: appState.strokeWidth)
                        .frame(width: 24, height: 24)

                    Slider(value: $appState.strokeWidth, in: 1...30, step: 1)
                        .tint(appState.strokeColor.color)
                }
            }

            // Opacity
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Opacity")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                    Spacer()
                    Text("\(Int(appState.opacity * 100))%")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }

                Slider(value: $appState.opacity, in: 0.1...1.0, step: 0.05)
                    .tint(appState.strokeColor.color)
            }

            // Font Size (when text tool is active)
            if appState.selectedTool == .text {
                Divider().background(Color.white.opacity(0.15))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Font Size")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .textCase(.uppercase)
                        Spacer()
                        Text("\(Int(appState.fontSize))pt")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Slider(value: $appState.fontSize, in: 10...120, step: 2)
                        .tint(appState.strokeColor.color)

                    HStack(spacing: 8) {
                        Toggle(isOn: $appState.isBold) {
                            Image(systemName: "bold")
                        }
                        .toggleStyle(.button)

                        Toggle(isOn: $appState.isItalic) {
                            Image(systemName: "italic")
                        }
                        .toggleStyle(.button)

                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(nsColor: NSColor(white: 0.15, alpha: 0.95)))
                .shadow(color: .black.opacity(0.45), radius: 16, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
