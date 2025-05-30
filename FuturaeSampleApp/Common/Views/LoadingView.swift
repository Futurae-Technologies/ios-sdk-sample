//
//  CustomSpinner.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 13.3.25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    let size: CGSize
    
    init(size: CGSize = .init(width: 80, height: 80)) {
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.spinnerBg, lineWidth: 4)
                .frame(width: size.width, height: size.height)
            
            Circle()
                .trim(from: 0.2, to: 1.0) 
                .stroke(Color.spinner, lineWidth: 4)
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
