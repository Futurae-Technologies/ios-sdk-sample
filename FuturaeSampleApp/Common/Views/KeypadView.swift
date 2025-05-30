//
//  KeypadView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 4.3.25.
//

import SwiftUI

struct KeypadView: View {
    @Binding var enteredPin: String
    let maxLength: Int
    let onComplete: () -> Void
    
    let deleteKey = "delete"
    let blankKey = ""
    
    private var digits: [[String]] {
        [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [blankKey, "0", deleteKey]
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(digits, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { digit in
                        Button(action: {
                            tapped(digit)
                        }) {
                            if digit == deleteKey {
                                Image(ImageAsset.back)
                                    .foregroundColor(Color.semanticGreen)
                            } else if digit == blankKey {
                                Spacer()
                            } else {
                                Text(digit)
                                    .font(.titleH1)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.neutralWhite)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func tapped(_ digit: String) {
        if digit == deleteKey {
            _ = enteredPin.popLast()
        } else if digit != blankKey {
            guard enteredPin.count < maxLength else { return }
            enteredPin.append(digit)
            if enteredPin.count == maxLength {
                onComplete()
            }
        }
    }
}
