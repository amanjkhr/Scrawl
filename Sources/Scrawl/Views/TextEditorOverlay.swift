import SwiftUI

/// Floating text editor overlay that appears on the canvas when the text tool is used.
struct TextEditorOverlay: View {
    @ObservedObject var appState: AppState
    @FocusState private var isFocused: Bool

    var body: some View {
        if appState.isEditingText {
            VStack(alignment: .leading, spacing: 0) {
                // Text input
                TextField("Type here...", text: $appState.editingTextValue, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: appState.fontSize))
                    .foregroundColor(appState.strokeColor.color)
                    .focused($isFocused)
                    .lineLimit(1...10)
                    .frame(minWidth: 100, maxWidth: 500)
                    .padding(8)
                    .onSubmit {
                        commitText()
                    }
                    .onExitCommand {
                        cancelText()
                    }

                // Mini toolbar
                HStack(spacing: 8) {
                    Button {
                        commitText()
                    } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button {
                        cancelText()
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
            )
            .position(
                x: appState.editingTextPosition.x + 100,
                y: appState.editingTextPosition.y
            )
            .onAppear {
                isFocused = true
            }
        }
    }

    private func commitText() {
        guard !appState.editingTextValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelText()
            return
        }

        let textElement = TextData(
            text: appState.editingTextValue,
            position: appState.editingTextPosition,
            fontSize: appState.fontSize,
            color: appState.strokeColor,
            isBold: appState.isBold,
            isItalic: appState.isItalic
        )
        appState.addElement(.text(textElement))
        appState.isEditingText = false
        appState.editingTextValue = ""
    }

    private func cancelText() {
        appState.isEditingText = false
        appState.editingTextValue = ""
    }
}
