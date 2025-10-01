import XCTest
@testable import MorseCore

final class MorseEncoderTests: XCTestCase {
    var encoder: MorseEncoder!

    override func setUp() {
        super.setUp()
        encoder = MorseEncoder()
    }

    override func tearDown() {
        encoder = nil
        super.tearDown()
    }

    func testEncodeSingleLetter() throws {
        XCTAssertEqual(try encoder.encode("A"), ".-")
    }

    func testEncodeSingleWord() throws {
        XCTAssertEqual(try encoder.encode("HELLO"), ".... . .-.. .-.. ---")
    }

    func testEncodeMultipleWords() throws {
        XCTAssertEqual(try encoder.encode("HELLO WORLD"), ".... . .-.. .-.. --- / .-- --- .-. .-.. -..")
    }

    func testEncodeNumbers() throws {
        XCTAssertEqual(try encoder.encode("123"), ".---- ..--- ...--")
    }

    func testEncodePunctuation() throws {
        XCTAssertEqual(try encoder.encode("SOS!"), "... --- ... -.-.--")
    }

    func testEncodeWhitespaceOnly() throws {
        XCTAssertEqual(try encoder.encode("   "), "/")
    }

    func testEncodeUnknownCharacterThrows() {
        XCTAssertThrowsError(try encoder.encode("A#"))
    }
}
