import XCTest
import AppKit
@testable import Dotpad

final class StorageTests: XCTestCase {
    var tmp: URL!
    var storage: Storage!

    override func setUpWithError() throws {
        tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("DotpadTests-\(UUID().uuidString)")
        storage = Storage(baseURL: tmp)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tmp)
    }

    func testIndexRoundTrip() {
        let dots = [
            Dot(order: 0, colorHex: "#FFFFFF", mode: .rich),
            Dot(order: 1, colorHex: "#000000", mode: .plain),
        ]
        let index = Storage.Index(version: 1, dots: dots, activeDotId: dots[0].id)
        storage.saveIndex(index)
        let loaded = storage.loadIndex()
        XCTAssertEqual(loaded?.dots.count, 2)
        XCTAssertEqual(loaded?.activeDotId, dots[0].id)
        XCTAssertEqual(loaded?.dots[1].mode, .plain)
    }

    func testPlainContentRoundTrip() {
        let dot = Dot(order: 0, colorHex: "#FFFFFF", mode: .plain)
        storage.saveContent(NSAttributedString(string: "hello plain"), for: dot)
        XCTAssertEqual(storage.loadContent(for: dot).string, "hello plain")
    }

    func testRichContentRoundTrip() {
        let dot = Dot(order: 0, colorHex: "#FFFFFF", mode: .rich)
        let attr = NSAttributedString(
            string: "bold bit",
            attributes: [.font: NSFont.boldSystemFont(ofSize: 14)]
        )
        storage.saveContent(attr, for: dot)
        XCTAssertEqual(storage.loadContent(for: dot).string, "bold bit")
    }

    func testDeleteContent() {
        let dot = Dot(order: 0, colorHex: "#FFFFFF", mode: .plain)
        storage.saveContent(NSAttributedString(string: "x"), for: dot)
        storage.deleteContent(for: dot)
        XCTAssertEqual(storage.loadContent(for: dot).string, "")
    }
}
