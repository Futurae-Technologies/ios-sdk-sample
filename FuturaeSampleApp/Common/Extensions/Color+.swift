//
//  Color+.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 12.3.25.
//

import SwiftUI
import UIKit

extension Color {
    static let neutralBlack = Color(hex: "#000000")
    static let neutralGrey = Color(hex: "#808080")
    static let neutralLightGrey = Color(hex: "#DADADA")
    static let neutralWhite = Color(hex: "#FFFFFF")
    static let errorRed = Color(hex: "#FF0000")
    static let successGreen = Color(hex: "#008000")
    static let warningOrange = Color(hex: "#FFA500")
    static let deepPurple = Color(hex: "#57577B")
    static let mediumPurple = Color(hex: "#73738F")
    static let lightPurple = Color(hex: "#A7A6C5")
    
    static let inactive = Color(hex: "#A6A5BB")
    static let bgNavbar = mainColor
    static let bgHeader = mainColor
    static let screenBg = mainColor
    static let textDark = mainColor
    static let textAlt = Color(hex: "#A6A5BB")
    static let semanticGreen = Color(hex: "#5FB97D")
    static let inputBg = Color(hex: "#F0F0F0")
    static let btnDisabled = Color(hex: "#D0D0D0")
    static let btnReject = Color(hex: "#D75014")
    static let btnRed = Color(hex: "#D75014")
    static let textError = Color(hex: "#D75014")
    static let emptyState = Color(hex: "#D0D0D0")
    static let fillState = Color(hex: "#5FB97D")
    static let altBg = Color(hex: "#555470")
    static let spinnerBg = Color(hex: "#D0D0D0")
    static let spinner = Color(hex: "#5FB97D")
    
    static let mainColor = Color(hex: "#303042")
    
    var uiColor: UIColor {
        .init(self)
    }

    init(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }

        if cString.count != 6 {
            self.init(white: 0.5)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
