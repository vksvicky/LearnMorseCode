import SwiftUI

extension Font {
    static func robotoMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "RobotoMono-Bold"
        case .medium, .semibold:
            fontName = "RobotoMono-Medium"
        default:
            fontName = "RobotoMono-Regular"
        }
        
        return .custom(fontName, size: size)
    }
}
