import AppKit
import UniformTypeIdentifiers

/// Handles saving, loading, and exporting whiteboard documents.
final class ScrawlFileManager {

    static let shared = ScrawlFileManager()
    private init() {}

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    // MARK: - Save

    func save(document: ScrawlDocument, to url: URL? = nil) throws -> URL {
        let data = try encoder.encode(document)

        if let url = url {
            try data.write(to: url, options: .atomic)
            return url
        }

        // Show save panel
        let panel = NSSavePanel()
        panel.title = "Save Scrawl Document"
        panel.allowedContentTypes = [UTType(filenameExtension: "scrawl") ?? .json]
        panel.nameFieldStringValue = "Untitled.scrawl"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else {
            throw ScrawlFileError.cancelled
        }

        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Load

    func load(from url: URL? = nil) throws -> ScrawlDocument {
        let fileURL: URL

        if let url = url {
            fileURL = url
        } else {
            let panel = NSOpenPanel()
            panel.title = "Open Scrawl Document"
            panel.allowedContentTypes = [UTType(filenameExtension: "scrawl") ?? .json]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false

            guard panel.runModal() == .OK, let url = panel.url else {
                throw ScrawlFileError.cancelled
            }
            fileURL = url
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(ScrawlDocument.self, from: data)
    }

    // MARK: - Export PNG

    func exportPNG(elements: [DrawingElement], size: CGSize, backgroundColor: CodableColor) throws -> URL {
        let panel = NSSavePanel()
        panel.title = "Export as PNG"
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "Scrawl Export.png"

        guard panel.runModal() == .OK, let url = panel.url else {
            throw ScrawlFileError.cancelled
        }

        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        NSGraphicsContext.saveGraphicsState()
        let gfxContext = NSGraphicsContext(bitmapImageRep: bitmapRep)!
        NSGraphicsContext.current = gfxContext

        let cgContext = gfxContext.cgContext

        // Background
        cgContext.setFillColor(backgroundColor.cgColor)
        cgContext.fill(CGRect(origin: .zero, size: size))

        // Render elements
        let engine = DrawingEngine()
        engine.render(elements: elements, in: cgContext)

        NSGraphicsContext.restoreGraphicsState()

        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw ScrawlFileError.exportFailed
        }

        try pngData.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Export PDF

    func exportPDF(elements: [DrawingElement], size: CGSize, backgroundColor: CodableColor) throws -> URL {
        let panel = NSSavePanel()
        panel.title = "Export as PDF"
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "Scrawl Export.pdf"

        guard panel.runModal() == .OK, let url = panel.url else {
            throw ScrawlFileError.cancelled
        }

        let pdfData = NSMutableData()
        var mediaBox = CGRect(origin: .zero, size: size)

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ScrawlFileError.exportFailed
        }

        pdfContext.beginPage(mediaBox: &mediaBox)

        // Background
        pdfContext.setFillColor(backgroundColor.cgColor)
        pdfContext.fill(mediaBox)

        // Render elements
        let engine = DrawingEngine()
        engine.render(elements: elements, in: pdfContext)

        pdfContext.endPage()
        pdfContext.closePDF()

        try pdfData.write(to: url, options: .atomic)
        return url
    }
}

// MARK: - Errors

enum ScrawlFileError: LocalizedError {
    case cancelled
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .cancelled: return "Operation cancelled."
        case .exportFailed: return "Failed to export the document."
        }
    }
}
