//
//  ManualEntryViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

final class ManualEntryViewModel: ObservableObject {
    @Published var shortCode: String = ""
    
    var isSubmitDisabled: Bool {
        shortCode.count < 16
    }
    
    func submitShortCode() {
        guard !isSubmitDisabled else { return }
        
        NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .shortCode(code: shortCode)))
    }

    func formatActivationCode(_ activationCode: String) {
        let cleaned = activationCode.replacingOccurrences(of: " ", with: "")
        let grouped = cleaned.chunked(into: 4).joined(separator: " ")
        let code = grouped.prefix(19).description
        if code != activationCode {
            shortCode = code
        }
    }
}
