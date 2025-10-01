import SwiftUI

public struct MorseCodeCard: View {
    let character: String
    let morseCode: String
    let onTap: (() -> Void)?
    @State private var isPressed = false
    public init(character: String, morseCode: String, onTap: (() -> Void)? = nil) {
        self.character = character
        self.morseCode = morseCode
        self.onTap = onTap
    }
    public var body: some View {
        VStack(spacing: 12) {
            // Character - larger and more prominent
            Text(character)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
            // Morse code - more prominent with better spacing
            Text(morseCode)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)}
        .frame(minWidth: 80, minHeight: 40)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isPressed ? Color(.controlAccentColor).opacity(0.1) :
                      Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(isPressed ? 0.12 : 0.08),
                       radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPressed ? Color(.controlAccentColor).opacity(0.3) :
                        Color(.separatorColor).opacity(0.5),
                       lineWidth: isPressed ? 2 : 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            onTap?()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
