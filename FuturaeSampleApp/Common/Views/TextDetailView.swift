//
//  TextDetailView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 16.3.25.
//

import SwiftUI

struct TextDetailView: View {
    let title: String
    let text: String
    
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(title: title, dismissType: .close, titleFont: .header4)
                Text(text)
                    .padding()
            }
        }
    }
}
