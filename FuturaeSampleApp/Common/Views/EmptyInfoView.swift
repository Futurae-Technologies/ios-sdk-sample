//
//  EmptyInfoView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 13.3.25.
//

import SwiftUI

struct EmptyInfoView: View {
    let image: ImageAsset?
    let title: String?
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 48) {
            if let image = image {
                Image(image)
            }
            
            
            VStack(spacing: 16){
                if let title = title {
                    Text(title)
                        .font(.header4)
                        .foregroundColor(Color.textDark)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundColor(Color.textDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
