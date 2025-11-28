//
//  BannerView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI

struct BannerView: View {
    let banner: MigrationBanner
    let onTap: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(ImageAsset.restore)
            
            VStack(alignment:. leading) {
                Text(String.restoreAccountsAvailable)
                    .font(.header5)
                    .foregroundColor(Color.neutralWhite)
                
                Text(banner.message)
                    .font(.bodySmall)
                    .foregroundColor(Color.neutralWhite)
            }
            
            Spacer()
            
            Button(action: onClose) {
                Image(ImageAsset.close)
            }
        }
        .padding(.all, 8)
        .background(bannerBackgroundColor)
        .onTapGesture {
            onTap()
        }
    }
    
    private var bannerBackgroundColor: Color {
        switch banner {
        case .success: return Color.semanticGreen
        case .failure: return Color.warningOrange
        }
    }
}
