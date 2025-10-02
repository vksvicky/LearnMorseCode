import SwiftUI

// Global font configuration
public struct AppFonts {
    public static let primarySize: CGFloat = 18
    public static let largeSize: CGFloat = 24
    public static let smallSize: CGFloat = 14
    
    public static func primary(weight: Font.Weight = .regular) -> Font {
        return robotoMono(size: primarySize, weight: weight)
    }

    public static func large(weight: Font.Weight = .regular) -> Font {
        return robotoMono(size: largeSize, weight: weight)
    }

    public static func small(weight: Font.Weight = .regular) -> Font {
        return robotoMono(size: smallSize, weight: weight)
    }

    public static func robotoMono(size: CGFloat, weight: Font.Weight) -> Font {
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

extension Font {
    public static func robotoMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return AppFonts.robotoMono(size: size, weight: weight)
    }
}
