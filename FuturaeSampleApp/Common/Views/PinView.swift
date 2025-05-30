//
//  PinView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 4.3.25.
//


import SwiftUI

struct PinView: View {
    @Environment(\.dismiss) private var dismiss
    @State var pin: String = ""
    let maxPinLength = 4
    let title: String
    let onFinish: ((String?) -> Void)
    
    init(title: String, onFinish: @escaping ((String?) -> Void)) {
        self.title = title
        self.onFinish = onFinish
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(ImageAsset.closeLarge)
                            .foregroundColor(Color.neutralWhite)
                    }
                }
                .padding(.all, 20)
                
                Spacer()
                
                Image(ImageAsset.futurae)
                
                Text(title)
                    .font(.header5)
                    .foregroundStyle(Color.neutralWhite)
                
                
                HStack(spacing: 12) {
                    ForEach(0..<maxPinLength, id: \.self) { index in
                        Circle()
                            .fill(index < pin.count ? Color.fillState : Color.emptyState)
                            .frame(width: 12, height: 12)
                    }
                }
                
                KeypadView(
                    enteredPin: $pin,
                    maxLength: maxPinLength,
                    onComplete: {
                        dismiss()
                    }
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.screenBg)
        .onDisappear(perform: { onFinish(pin) })
    }
}
