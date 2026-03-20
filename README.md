# Scrawl

A native macOS whiteboarding app for instructors and presenters. Draw freehand, add shapes and text, annotate over your screen, and export your work — all from a beautiful, lightweight native app.

## Features

- ✏️ **Freehand Drawing** — Pen & Highlighter with Catmull-Rom spline smoothing
- 🔷 **Shapes** — Line, Rectangle, Ellipse, Arrow with live preview
- 🔤 **Text Tool** — Click anywhere to type with font size, bold/italic controls
- 🧹 **Eraser** — Stroke-level erasing
- 🔴 **Laser Pointer** — Red dot with fading trail for presentations
- 🖥️ **Screen Overlay Mode** — Draw over your entire screen (⌘B)
  - Features its own floating toolbar and color picker for quick mid-presentation changes
  - Activating overlay hides the main Scrawl window so it won't obscure slides
  - Uses an infallible Carbon global hotkey to guarantee `⌘B` works natively across your system
- 📄 **Multi-Page Canvas** — Add, delete, and switch between pages
- 🎨 **10 Color Presets** + custom color picker, stroke width (1–30pt), opacity
- ↩️ **Undo/Redo** — Full stack with ⌘Z / ⌘⇧Z
- 💾 **Save/Load** — `.scrawl` files, export as PNG or PDF
- 📌 **Menu Bar Icon** — Quick access to tools and overlay toggle
- ⌨️ **18 Keyboard Shortcuts** — Rapid tool switching

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+

## Build & Install

```bash
# Clone the repo
git clone https://github.com/amanjkhr/Scrawl.git
cd Scrawl

# Build and install
./build.sh
```

Or build manually:

```bash
swift build -c release
# The .app bundle is at ./Scrawl.app
# Copy to /Applications for Dock access
cp -R Scrawl.app /Applications/
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `P` | Pen |
| `H` | Highlighter |
| `E` | Eraser |
| `T` | Text |
| `L` | Line |
| `R` | Rectangle |
| `O` | Ellipse |
| `A` | Arrow |
| `⌘Z` | Undo |
| `⌘⇧Z` | Redo |
| `⌘B` | Toggle Overlay (Global) |
| `⌘S` | Save |
| `⌘⇧E` | Export |
| `⌘N` | New Page |
| `Esc` | Exit Overlay |

## Project Structure

```
Sources/Scrawl/
├── App/                  # App entry, delegate, global state
│   ├── ScrawlApp.swift   # @main, WindowGroup, MenuBarExtra, shortcuts
│   ├── AppDelegate.swift # NSApplicationDelegate for dock/lifecycle
│   └── AppState.swift    # ObservableObject: tools, pages, undo/redo
├── Models/               # Data types
│   ├── Tool.swift        # Tool enum (pen, highlighter, eraser, shapes, text, laser)
│   ├── DrawingElement.swift  # Stroke, Shape, Text element types + CodableColor
│   └── CanvasPage.swift  # Multi-page document model
├── Drawing/              # Core rendering engine
│   ├── DrawingEngine.swift           # CGContext rendering + hit testing
│   ├── DrawingCanvasView.swift       # NSView with mouse/trackpad handling
│   └── DrawingCanvasRepresentable.swift  # SwiftUI wrapper
├── Views/                # UI components
│   ├── ContentView.swift       # Main layout
│   ├── ToolbarView.swift       # Floating glass tool palette
│   ├── ColorPickerView.swift   # Color swatches + stroke controls
│   ├── PageNavigatorView.swift # Page thumbnail sidebar
│   └── TextEditorOverlay.swift # In-canvas text input
├── Overlay/              # Screen overlay mode
│   ├── OverlayWindowController.swift  # Transparent fullscreen NSWindow
│   ├── OverlayManager.swift          # Toggle overlay on/off
│   ├── OverlayContentView.swift      # Overlay-specific SwiftUI layout with tools
│   └── GlobalHotkeyManager.swift     # Carbon framework system-wide hotkey
└── Services/
    └── ScrawlFileManager.swift  # Save/load .scrawl, export PNG/PDF
```

## Architecture

The app uses **SwiftUI** for window management and UI composition, backed by a custom **AppKit `NSView`** canvas for high-performance Core Graphics drawing. The overlay mode creates a borderless transparent `NSWindow` at `.screenSaver` level to draw over any content on screen.

All drawing elements are `Codable`, enabling native JSON serialization for the `.scrawl` file format.

## Tech Stack

- **Swift 5** + **SwiftUI** + **AppKit**
- **Core Graphics** for high-performance rendering
- **Swift Package Manager** (no Xcode project needed)

## License

MIT
