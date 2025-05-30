//
//  Font+.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 12.3.25.
//

import SwiftUI
import UIKit

extension UIFont {
    static func font(_ style: CustomFontStyle) -> UIFont {
        style.uiFont
    }
}

extension Font {
    static func font(_ style: CustomFontStyle) -> Font {
        style.font
    }
}

extension View {
    func font(_ style: CustomFontStyle, spacing: Bool = true) -> some View {
        self
            .font(style.font)
            .modifier(ConditionalLineSpacingModifier(isEnabled: spacing, spacing: style.lineHeight - style.size))
    }
}

private struct ConditionalLineSpacingModifier: ViewModifier {
    let isEnabled: Bool
    let spacing: CGFloat

    func body(content: Content) -> some View {
        if isEnabled {
            content.lineSpacing(spacing)
        } else {
            content
        }
    }
}


enum CustomFontStyle {
    case titleH1
    case titleH2
    case titleH3
    case header4
    case header5
    case button
    case bodyLarge
    case link
    case bodySmall
    case menu
    
    var uiFont: UIFont {
        .init(name: fontName, size: size)!
    }

    var font: Font {
        .custom(fontName, size: size)
    }
    
    var fontName: String {
        switch self {
        case .bodyLarge, .bodySmall:
            return "HelveticaNeue"
        default:
            return "HelveticaNeue-Bold"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .titleH1:
            return 32
        case .titleH2:
            return 28
        case .titleH3:
            return 24
        case .header4:
            return 20
        case .header5:
            return 16
        case .button:
            return 18
        case .bodyLarge:
            return 18
        case .link:
            return 16
        case .bodySmall:
            return 14
        case .menu:
            return 12
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .titleH1:
            return 34
        case .titleH2:
            return 30
        case .titleH3:
            return 28
        case .header4:
            return 24
        case .header5:
            return 20
        case .button:
            return 22
        case .bodySmall:
            return 18
        case .bodyLarge:
            return 20
        case .link:
            return 18
        case .menu:
            return 18
        }
    }
}
