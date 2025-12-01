//
//  HeaderView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 13.3.25.
//

import SwiftUI

enum DismissButtonType {
    case back
    case close
}

struct HeaderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let title: String?
    let subtitle: String?
    let imageURL: String?
    let image: ImageAsset?
    let dismissType: DismissButtonType?
    let titleFont: CustomFontStyle
    let progress: Bool
    let paddingBottom: CGFloat
    
    init(title: String? = nil,
         subtitle: String? = nil,
         imageURL: String? = nil,
         image: ImageAsset? = nil,
         dismissType: DismissButtonType? = nil,
         titleFont: CustomFontStyle = .titleH2,
         progress: Bool = false,
         paddingBottom: CGFloat = 32
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.image = image
        self.dismissType = dismissType
        self.titleFont = titleFont
        self.progress = progress
        self.paddingBottom = paddingBottom
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if let dismissType = dismissType {
                HStack {
                    if dismissType == .close {
                        Spacer()
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(dismissType == .close ? ImageAsset.closeLarge :  ImageAsset.arrow)
                            .foregroundColor(Color.neutralWhite)
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIdentifier("header_back_button")
                    }
                    
                    if dismissType == .back {
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            }
            
            VStack(alignment: .center, spacing: 16) {
                if progress {
                    LoadingView()
                }
                
                if let imageURL = imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 72, height: 72)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
                        default:
                            EmptyView()
                        }
                    }
                }
                
                if let image = image {
                    Image(image)
                }
                
                if let title = title {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(Color.neutralWhite)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundColor(Color.textAlt)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, paddingBottom)
        .background(Color.bgHeader)
    }
}
