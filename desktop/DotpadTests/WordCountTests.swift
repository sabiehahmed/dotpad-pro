import XCTest
@testable import Dotpad

final class WordCountTests: XCTestCase {

    func testEmpty() {
        XCTAssertEqual(DotStore.computeStats(""), DocStats(lines: 0, words: 0, characters: 0))
    }

    func testSingleLine() {
        let s = DotStore.computeStats("hello world")
        XCTAssertEqual(s.words, 2)
        XCTAssertEqual(s.lines, 1)
        XCTAssertEqual(s.characters, 11)
    }

    func testMultiLine() {
        let s = DotStore.computeStats("a\nb\nc")
        XCTAssertEqual(s.lines, 3)
        XCTAssertEqual(s.words, 3)
        XCTAssertEqual(s.characters, 5)
    }
}
