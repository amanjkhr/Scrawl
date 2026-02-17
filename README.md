# Scrawl

A native macOS whiteboarding app for instructors and presenters. Draw freehand, add shapes and text, annotate over your screen, and export your work — all from a beautiful, lightweight native app.

## Features

- ✏️ **Freehand Drawing** — Pen & Highlighter with Catmull-Rom spline smoothing
- 🔷 **Shapes** — Line, Rectangle, Ellipse, Arrow with live preview
- 🔤 **Text Tool** — Click anywhere to type with font size, bold/italic controls
- 🧹 **Eraser** — Stroke-level erasing
- 🔴 **Laser Pointer** — Red dot with fading trail for presentations
- 🖥️ **Screen Overlay Mode** — Draw over your entire screen (⌘⇧O)
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
git clone https://github.com/YOUR_USERNAME/Scrawl.git
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
| `⌘⇧O` | Toggle Overlay |
| `⌘S` | Save |
| `⌘⇧E` | Export |
| `⌘N` | New Page |
| `Esc` | Exit Overlay |

## Tech Stack

- **Swift 5** + **SwiftUI** + **AppKit**
- **Core Graphics** for high-performance rendering
- **Swift Package Manager** (no Xcode project needed)

## License

MIT
