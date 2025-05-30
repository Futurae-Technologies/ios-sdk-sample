//
//  ManualEntryView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI

struct ManualEntryView: View {
    @StateObject private var viewModel = ManualEntryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(ImageAsset.manualEntryImage)
                    
                    Text(String.pleaseEnterTheActivationCodeThatWasProvidedToYou)
                        .font(.header5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.textDark)
                    
                    TextField("0000 0000 0000 0000", text: $viewModel.shortCode)
                        .frame(height: 70)
                        .font(.header4)
                        .foregroundStyle(Color.textDark)
                        .multilineTextAlignment(.center)
                        .background(Color.inputBg)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .overlay(Rectangle().frame(height: 2).foregroundColor(Color.textDark), alignment: .bottom)
                        .onChange(of: viewModel.shortCode) { viewModel.formatActivationCode($1)}
                        
                    
                    Spacer()
                    
                    RoundedButton(title: String.submit, icon: nil, action: viewModel.submitShortCode,
                                  style: viewModel.isSubmitDisabled ? .disabled : .primary, isFullWidth: true)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .navigationTitle(String.bottomNavigationManualEntryItem)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView()
    }
}

