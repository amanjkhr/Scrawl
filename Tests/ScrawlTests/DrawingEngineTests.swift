import XCTest
@testable import Scrawl

final class DrawingEngineTests: XCTestCase {

    func testStrokeDataCreation() {
        let points = [
            StrokePoint(CGPoint(x: 0, y: 0)),
            StrokePoint(CGPoint(x: 10, y: 10)),
            StrokePoint(CGPoint(x: 20, y: 5)),
        ]
        let stroke = StrokeData(
            points: points,
            color: .red,
            lineWidth: 5.0,
            opacity: 1.0
        )
        XCTAssertEqual(stroke.points.count, 3)
        XCTAssertEqual(stroke.lineWidth, 5.0)
        XCTAssertFalse(stroke.isHighlighter)
    }

    func testStrokeBoundingRect() {
        let points = [
            StrokePoint(CGPoint(x: 10, y: 20)),
            StrokePoint(CGPoint(x: 50, y: 60)),
        ]
        let stroke = StrokeData(points: points, lineWidth: 4.0)
        let rect = stroke.boundingRect
        XCTAssertTrue(rect.contains(CGPoint(x: 10, y: 20)))
        XCTAssertTrue(rect.contains(CGPoint(x: 50, y: 60)))
    }

    func testShapeDataBoundingRect() {
        let shape = ShapeData(
            shapeType: .rectangle,
            origin: CGPoint(x: 100, y: 100),
            size: CGSize(width: 200, height: 150),
            lineWidth: 2.0
        )
        let rect = shape.boundingRect
        XCTAssertTrue(rect.width >= 200)
        XCTAssertTrue(rect.height >= 150)
    }

    func testTextDataCreation() {
        let text = TextData(
            text: "Hello, World!",
            position: CGPoint(x: 50, y: 50),
            fontSize: 24.0,
            color: .white
        )
        XCTAssertEqual(text.text, "Hello, World!")
        XCTAssertEqual(text.fontSize, 24.0)
        XCTAssertFalse(text.isBold)
    }

    func testCodableColorPresets() {
        XCTAssertEqual(CodableColor.presets.count, 10)
        XCTAssertEqual(CodableColor.white.red, 1.0)
        XCTAssertEqual(CodableColor.black.red, 0.0)
    }

    func testCodableColorRoundTrip() throws {
        let original = CodableColor.blue
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CodableColor.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testCanvasPageCreation() {
        var page = CanvasPage(label: "Test Page")
        XCTAssertTrue(page.elements.isEmpty)
        XCTAssertEqual(page.label, "Test Page")

        let stroke = StrokeData(
            points: [StrokePoint(CGPoint(x: 0, y: 0))],
            color: .white,
            lineWidth: 3.0
        )
        page.elements.append(.stroke(stroke))
        XCTAssertEqual(page.elements.count, 1)

        page.clearAll()
        XCTAssertTrue(page.elements.isEmpty)
    }

    func testToolProperties() {
        XCTAssertTrue(Tool.pen.isStrokeTool)
        XCTAssertTrue(Tool.highlighter.isStrokeTool)
        XCTAssertFalse(Tool.eraser.isStrokeTool)
        XCTAssertTrue(Tool.rectangle.isShapeTool)
        XCTAssertEqual(Tool.highlighter.defaultOpacity, 0.35)
        XCTAssertEqual(Tool.pen.defaultOpacity, 1.0)
    }

    func testScrawlDocumentSerialization() throws {
        let doc = ScrawlDocument(
            pages: [CanvasPage(label: "Page 1")],
            currentPageIndex: 0
        )
        let data = try JSONEncoder().encode(doc)
        let decoded = try JSONDecoder().decode(ScrawlDocument.self, from: data)
        XCTAssertEqual(decoded.pages.count, 1)
        XCTAssertEqual(decoded.currentPageIndex, 0)
        XCTAssertEqual(decoded.pages[0].label, "Page 1")
    }
}
