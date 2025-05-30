//
//  RoundedButton.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 12.3.25.
//

import SwiftUI

struct RoundedButton: View {
    let title: String
    let icon: ImageAsset?
    let action: () -> Void
    let style: ButtonStyleType
    let isFullWidth: Bool

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                }
                Text(title)
                    .font(.button)
            }
            .foregroundColor(style.textColor)
            .padding()
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(style.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(style.borderColor, lineWidth: 2)
            )
            .cornerRadius(32)
        }
        .disabled(style == .disabled || style == .outlinedDisabled)
    }
}


enum ButtonStyleType {
    case primary
    case success
    case reject
    case disabled
    case outlined
    case outlinedDisabled

    var backgroundColor: Color? {
        switch self {
        case .primary: return Color.textDark
        case .success: return Color.successGreen
        case .reject: return Color.btnReject
        case .disabled: return Color.btnDisabled
        case .outlined, .outlinedDisabled: return nil
        }
    }

    var borderColor: Color {
        switch self {
        case .outlined: return Color.textDark
        case .outlinedDisabled: return Color.btnDisabled
        default: return .clear
        }
    }

    var textColor: Color {
        switch self {
        case .outlined: return Color.textDark
        case .outlinedDisabled: return Color.btnDisabled
        default: return Color.neutralWhite
        }
    }
}
