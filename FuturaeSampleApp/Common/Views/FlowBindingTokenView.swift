//
//  FlowBindingTokenView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 5.3.25.
//


import SwiftUI

struct FlowBindingTokenView: View {
    @State var token: String = ""
    var isSubmitDisabled: Bool { token.isEmpty }
    
    let onFinish: ((String?) -> Void)
    
    init(onFinish: @escaping ((String?) -> Void)) {
        self.onFinish = onFinish
    }
    
    var body: some View {
        ZStack {
            VStack {
                HeaderView(title: String.flowBindingToken, dismissType: .close, titleFont: .header4)
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(ImageAsset.manualEntryImage)
                    
                    Text(String.flowBindingTokenPrompt)
                        .font(.header5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.textDark)
                    
                    TextField("", text: $token)
                        .frame(height: 70)
                        .font(.header4)
                        .foregroundStyle(Color.textDark)
                        .multilineTextAlignment(.center)
                        .background(Color.inputBg)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .overlay(Rectangle().frame(height: 2).foregroundColor(Color.textDark), alignment: .bottom)
                    
                    
                    Spacer()
                    
                    RoundedButton(title: String.submit, icon: nil, action: { onFinish(token) }, style: isSubmitDisabled ? .disabled : .primary, isFullWidth: true)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}
