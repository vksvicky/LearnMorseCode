import SwiftUI
import LearnMorseUI
import MorseCore

public struct MorseReferenceView: View {
    @EnvironmentObject private var morseModel: MorseCodeModel
    @State private var searchText = ""
    @State private var selectedCategory = Category.letters
    public init() {}
    enum Category: String, CaseIterable {
        case letters = "Letters"
        case numbers = "Numbers"
        case punctuation = "Punctuation"
    }
    private let morseData: [Category: [(String, String)]] = [
        .letters: [
            ("A", ".-"), ("B", "-..."), ("C", "-.-."), ("D", "-.."), ("E", "."),
            ("F", "..-."), ("G", "--."), ("H", "...."), ("I", ".."), ("J", ".---"),
            ("K", "-.-"), ("L", ".-.."), ("M", "--"), ("N", "-."), ("O", "---"),
            ("P", ".--."), ("Q", "--.-"), ("R", ".-."), ("S", "..."), ("T", "-"),
            ("U", "..-"), ("V", "...-"), ("W", ".--"), ("X", "-..-"), ("Y", "-.--"), ("Z", "--..")
        ],
        .numbers: [
            ("0", "-----"), ("1", ".----"), ("2", "..---"), ("3", "...--"), ("4", "....-"),
            ("5", "....."), ("6", "-...."), ("7", "--..."), ("8", "---.."), ("9", "----.")
        ],
        .punctuation: [
            (".", ".-.-.-"), (",", "--..--"), ("?", "..--.."), ("'", ".----."), ("!", "-.-.--"),
            ("/", "-..-."), ("(", "-.--."), (")", "-.--.-"), ("&", ".-..."), (":", "---..."),
            (";", "-.-.-."), ("=", "-...-"), ("+", ".-.-."), ("-", "-....-"), ("_", "..--.-"),
            ("\"", ".-..-."), ("$", "...-..-"), ("@", ".--.-.")
        ]
    ]
    private var filteredData: [(String, String)] {
        let data = morseData[selectedCategory] ?? []
        if searchText.isEmpty {
            return data
        }
        return data.filter { character, morse in
            character.localizedCaseInsensitiveContains(searchText) ||
            morse.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var adaptiveColumns: [GridItem] {
        // Responsive grid: fewer columns for better readability
        // 6 columns for letters, 5 for numbers, 4 for punctuation
        let columnCount: Int
        switch selectedCategory {
        case .letters:
            columnCount = 6
        case .numbers:
            columnCount = 5
        case .punctuation:
            columnCount = 4
        }

        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
    public var body: some View {
        VStack(spacing: 0) {
            // Search and filter controls
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search characters or Morse code...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
                .frame(maxWidth: 600)
                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 400)
            }.padding(.horizontal, 40)
            .padding(.top, 30)
            .padding(.bottom, 20)
            .background(Color(.windowBackgroundColor))

            Divider()
            // Character grid - responsive layout with better spacing
            ScrollView {
                LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                    ForEach(filteredData, id: \.0) { character, morse in
                        MorseCodeCard(character: character, morseCode: morse) {
                            morseModel.playMorseCode(morse)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
