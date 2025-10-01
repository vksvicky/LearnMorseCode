import XCTest
@testable import MorseCore

final class MorseDecoderTests: XCTestCase {
    var decoder: MorseDecoder!

    override func setUp() {
        super.setUp()
        decoder = MorseDecoder()
    }

    override func tearDown() {
        decoder = nil
        super.tearDown()
    }

    func testDecodeSingleLetter() throws {
        XCTAssertEqual(try decoder.decode(".-"), "A")
    }

    func testDecodeSingleWord() throws {
        XCTAssertEqual(try decoder.decode(".... . .-.. .-.. ---"), "HELLO")
    }

    func testDecodeMultipleWords() throws {
        XCTAssertEqual(try decoder.decode(".... . .-.. .-.. --- / .-- --- .-. .-.. -.."), "HELLO WORLD")
    }

    func testDecodeNumbers() throws {
        XCTAssertEqual(try decoder.decode(".---- ..--- ...--"), "123")
    }

    func testDecodePunctuation() throws {
        XCTAssertEqual(try decoder.decode("... --- ... -.-.--"), "SOS!")
    }

    func testDecodeWhitespaceOnly() throws {
        XCTAssertEqual(try decoder.decode("   "), "")
    }

    func testInvalidSequenceThrows() {
        XCTAssertThrowsError(try decoder.decode(".-x"))
    }
}
