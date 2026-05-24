import XCTest
@testable import Dotpad

final class SmartBulletsTests: XCTestCase {

    func testDetectsCircleBullet() {
        let b = SmartBullets.detect(line: "○ buy milk")
        XCTAssertEqual(b, SmartBullets.LineBullet(indent: "", marker: "○ "))
    }

    func testDetectsIndentedBullet() {
        let b = SmartBullets.detect(line: "\t\t● done")
        XCTAssertEqual(b, SmartBullets.LineBullet(indent: "\t\t", marker: "● "))
    }

    func testNoBulletOnPlainLine() {
        XCTAssertNil(SmartBullets.detect(line: "just text"))
    }

    func testEmptyBulletDetected() {
        let b = SmartBullets.detect(line: "○ ")!
        XCTAssertTrue(SmartBullets.isEmptyBullet(line: "○ ", bullet: b))
    }

    func testReturnContinuesList() {
        let action = SmartBullets.handleReturn(line: "○ task")
        XCTAssertEqual(action, .continueList(insert: "\n○ "))
    }

    func testReturnContinuesWithIndent() {
        let action = SmartBullets.handleReturn(line: "\t- thing")
        XCTAssertEqual(action, .continueList(insert: "\n\t- "))
    }

    func testReturnClearsEmptyBullet() {
        let action = SmartBullets.handleReturn(line: "○ ")
        XCTAssertEqual(action, .clearLine(prefixLength: 2))
    }

    func testReturnDefaultOnPlainLine() {
        XCTAssertEqual(SmartBullets.handleReturn(line: "hello"), .none)
    }

    func testTogglePairsAreSymmetric() {
        for (a, b) in SmartBullets.togglePairs {
            XCTAssertEqual(SmartBullets.togglePairs[b], a, "pair \(a)/\(b) not symmetric")
        }
    }
}
