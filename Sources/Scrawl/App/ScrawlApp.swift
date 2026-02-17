import SwiftUI

@main
struct ScrawlApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @State private var overlayManager: OverlayManager?

    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentView(appState: appState)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear {
                    if overlayManager == nil {
                        overlayManager = OverlayManager(appState: appState)
                    }
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1280, height: 800)
        .commands {
            // File menu
            CommandGroup(replacing: .newItem) {
                Button("New Page") {
                    appState.addPage()
                }
                .keyboardShortcut("n", modifiers: .command)

                Divider()

                Button("Save...") {
                    saveDocument()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Open...") {
                    loadDocument()
                }
                .keyboardShortcut("o", modifiers: .command)

                Divider()

                Button("Export as PNG...") {
                    exportPNG()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])

                Button("Export as PDF...") {
                    exportPDF()
                }
            }

            // Edit menu
            CommandGroup(replacing: .undoRedo) {
                Button("Undo") {
                    appState.undo()
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!appState.canUndo)

                Button("Redo") {
                    appState.redo()
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!appState.canRedo)

                Divider()

                Button("Clear Canvas") {
                    appState.clearCanvas()
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }

            // View menu
            CommandGroup(after: .toolbar) {
                Button("Toggle Page Navigator") {
                    withAnimation { appState.showPageNavigator.toggle() }
                }
                .keyboardShortcut("1", modifiers: .command)

                Divider()

                Button("Zoom In") {
                    appState.zoomIn()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    appState.zoomOut()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Reset Zoom") {
                    appState.resetZoom()
                }
                .keyboardShortcut("0", modifiers: .command)
            }

            // Tools menu
            CommandMenu("Tools") {
                ForEach(Tool.allCases) { tool in
                    Button(tool.label) {
                        appState.selectTool(tool)
                    }
                    .badge(appState.selectedTool == tool ? "✓" : "")
                    .disabled(false)
                }

                Divider()

                Button("Toggle Overlay Mode") {
                    overlayManager?.toggle()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }

        // Menu Bar Extra
        MenuBarExtra("Scrawl", systemImage: "pencil.tip.crop.circle") {
            menuBarContent
        }
    }

    // MARK: - Menu Bar Content

    @ViewBuilder
    private var menuBarContent: some View {
        Button("Show Scrawl") {
            NSApp.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("Toggle Overlay Mode  ⌘⇧O") {
            overlayManager?.toggle()
        }

        Divider()

        Menu("Tools") {
            ForEach(Tool.allCases) { tool in
                Button {
                    appState.selectTool(tool)
                } label: {
                    if appState.selectedTool == tool {
                        Label(tool.label, systemImage: "checkmark")
                    } else {
                        Text(tool.label)
                    }
                }
            }
        }

        Menu("Quick Colors") {
            ForEach(Array(CodableColor.presets.enumerated()), id: \.offset) { _, color in
                Button(colorName(color)) {
                    appState.strokeColor = color
                }
            }
        }

        Divider()

        Button("New Page") {
            appState.addPage()
        }

        Button("Clear Canvas") {
            appState.clearCanvas()
        }

        Divider()

        Button("Quit Scrawl") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    // MARK: - File Operations

    private func saveDocument() {
        let doc = ScrawlDocument(
            pages: appState.pages,
            currentPageIndex: appState.currentPageIndex
        )
        do {
            _ = try ScrawlFileManager.shared.save(document: doc)
        } catch ScrawlFileError.cancelled {
            // User cancelled, ignore
        } catch {
            print("Save error: \(error)")
        }
    }

    private func loadDocument() {
        do {
            let doc = try ScrawlFileManager.shared.load()
            appState.pages = doc.pages
            appState.currentPageIndex = doc.currentPageIndex
            appState.undoStack.removeAll()
            appState.redoStack.removeAll()
        } catch ScrawlFileError.cancelled {
            // User cancelled, ignore
        } catch {
            print("Load error: \(error)")
        }
    }

    private func exportPNG() {
        let page = appState.currentPage
        do {
            _ = try ScrawlFileManager.shared.exportPNG(
                elements: page.elements,
                size: CGSize(width: 1920, height: 1080),
                backgroundColor: page.backgroundColor
            )
        } catch ScrawlFileError.cancelled {
            // Ignore
        } catch {
            print("Export error: \(error)")
        }
    }

    private func exportPDF() {
        let page = appState.currentPage
        do {
            _ = try ScrawlFileManager.shared.exportPDF(
                elements: page.elements,
                size: CGSize(width: 1920, height: 1080),
                backgroundColor: page.backgroundColor
            )
        } catch ScrawlFileError.cancelled {
            // Ignore
        } catch {
            print("Export error: \(error)")
        }
    }

    private func colorName(_ color: CodableColor) -> String {
        if color == .white { return "White" }
        if color == .black { return "Black" }
        if color == .red { return "Red" }
        if color == .orange { return "Orange" }
        if color == .yellow { return "Yellow" }
        if color == .green { return "Green" }
        if color == .blue { return "Blue" }
        if color == .purple { return "Purple" }
        if color == .cyan { return "Cyan" }
        if color == .pink { return "Pink" }
        return "Custom"
    }
}
