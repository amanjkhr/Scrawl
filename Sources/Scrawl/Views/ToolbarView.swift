import SwiftUI

/// Floating tool palette with drawing tool buttons.
struct ToolbarView: View {
    @ObservedObject var appState: AppState

    private let drawingTools: [Tool] = [.pen, .highlighter, .eraser]
    private let shapeTools: [Tool] = [.line, .rectangle, .ellipse, .arrow]
    private let otherTools: [Tool] = [.text, .laser, .select]

    var body: some View {
        VStack(spacing: 0) {
            // Drawing tools
            toolSection(drawingTools)
            divider
            // Shape tools
            toolSection(shapeTools)
            divider
            // Other tools
            toolSection(otherTools)
            divider
            // Actions
            actionButtons
        }
        .padding(.vertical, 8)
        .frame(width: 48)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Tool Buttons

    @ViewBuilder
    private func toolSection(_ tools: [Tool]) -> some View {
        VStack(spacing: 2) {
            ForEach(tools) { tool in
                toolButton(tool)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func toolButton(_ tool: Tool) -> some View {
        Button {
            appState.selectTool(tool)
        } label: {
            Image(systemName: tool.icon)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 36, height: 36)
                .foregroundColor(
                    appState.selectedTool == tool
                        ? .white
                        : .white.opacity(0.6)
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            appState.selectedTool == tool
                                ? Color.accentColor.opacity(0.8)
                                : Color.clear
                        )
                )
        }
        .buttonStyle(.plain)
        .help(tool.label + (tool.shortcutKey.map { " (\($0.character))" } ?? ""))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 2) {
            // Undo
            actionButton(icon: "arrow.uturn.backward", enabled: appState.canUndo) {
                appState.undo()
            }
            .help("Undo (⌘Z)")

            // Redo
            actionButton(icon: "arrow.uturn.forward", enabled: appState.canRedo) {
                appState.redo()
            }
            .help("Redo (⌘⇧Z)")

            // Clear
            actionButton(icon: "trash", enabled: !appState.currentPage.elements.isEmpty) {
                appState.clearCanvas()
            }
            .help("Clear Canvas")

            // Color Picker toggle
            Button {
                appState.showColorPicker.toggle()
            } label: {
                Circle()
                    .fill(appState.strokeColor.color)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .help("Color & Stroke")
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func actionButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 36, height: 36)
                .foregroundColor(enabled ? .white.opacity(0.7) : .white.opacity(0.2))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
            .padding(.horizontal, 8)
    }
}
