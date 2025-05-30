//
//  AdaptivePermissionsView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 7.3.25.
//

import SwiftUI

struct AdaptivePermissionsView: View {
    @StateObject private var viewModel = AdaptivePermissionsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Permissions", dismissType: .back, titleFont: .header5, paddingBottom: 12)
            List(AdaptivePermission.allCases) { permission in
                Button {
                    viewModel.requestPermission(for: permission)
                } label: {
                    HStack {
                        Text(permission.rawValue)
                        Spacer()
                        Text(viewModel.statusText(for: permission))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear { viewModel.checkCurrentPermissions() }
        .navigationBarBackButtonHidden(true)
    }
}
