import XCTest
@testable import MorseCore

final class MorseCodeModelTests: XCTestCase {
    final class MockEncoder: MorseEncoding {
        var lastInput: String = ""
        var result: String = ""
        func encode(_ text: String) throws -> String {
            lastInput = text
            return result
        }
    }

    @MainActor
    func testTextToMorse_usesInjectedEncoder() {
        let mock = MockEncoder()
        mock.result = "... --- ..."
        let model = MorseCodeModel(encoder: mock)
        let output = model.textToMorseCode("SOS")
        XCTAssertEqual(output, "... --- ...")
        XCTAssertEqual(mock.lastInput, "SOS")
    }

    @MainActor
    func testTextToMorse_emptyInput() {
        let mock = MockEncoder()
        mock.result = ""
        let model = MorseCodeModel(encoder: mock)
        XCTAssertEqual(model.textToMorseCode(""), "")
    }
}
