//
//  AccountRowView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct AccountRowView: View {
    @StateObject var prefs = GlobalPreferences.shared
    @State var showLockedAlert = false
    
    let item: AccountItem
    let onGenerateHOTP: (FTRAccount) -> Void
    let onDelete: (FTRAccount) -> Void
    let onLogOut: (FTRAccount) -> Void
    let onGenerateTOTP: (FTRAccount, TOTPParameters) -> Void
    
    var lockedOut: Bool { item.account.lockedOut }
    
    var body: some View {
        if lockedOut {
            accountRowView
        } else {
            navigationRowView
        }
    }
    
    var accountRowView: some View {
        HStack {
            if let logoString = item.serviceLogo, let url = URL(string: logoString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 56, height: 56)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "building.2.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.serviceName)
                    .font(.header4)
                    .foregroundColor(Color.textDark)
                Text(item.username)
                    .font(.bodyLarge)
                    .foregroundColor(Color.textAlt)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            if lockedOut {
                Button(action: {
                    showLockedAlert.toggle()
                }) {
                    Image(ImageAsset.alert)
                }
            } else {
                Text(item.totp.spaced())
                    .font(.titleH2)
                    .foregroundColor(Color.textDark)
            }
        }
        .alert(isPresented: $showLockedAlert) {
            Alert(
                title: Text(String.lockedAccountInformativeDialogTitle),
                message: Text(String.lockedAccountInformativeDialogContent.replacingOccurrences(of: "$service", with: item.serviceName)),
                dismissButton: .default(Text(String.ok))
            )
        }
        .contextMenu {
            if !lockedOut {
                Button {
                    onGenerateHOTP(item.account)
                } label: {
                    Label(String.generateHotp, systemImage: "text.word.spacing")
                }
            }
            
            Button {
                onLogOut(item.account)
            } label: {
                Label(String.logOut, systemImage: "rectangle.portrait.and.arrow.right")
            }
            
            Button {
                onDelete(item.account)
            } label: {
                Label(String.deleteAccount, systemImage: "trash")
            }
            
            if prefs.sdkConfigData.lockType == .sdkPinWithBiometricsOptional {
                Button {
                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.pinInput(title: String.setupPin, callback: { pin in
                        onGenerateTOTP(item.account, .with(userId: item.account.userId, sdkPin: pin ?? ""))
                    }))
                } label: {
                    Label("\(String.generateHotp) (PIN)", systemImage: "pin")
                }
                
                Button {
                    onGenerateTOTP(item.account, .with(userId: item.account.userId, promptReason: String.pinBiometrics))
                } label: {
                    Label("\(String.generateHotp) (BIOMETRICS)", systemImage: "faceid")
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var navigationRowView: some View {
        NavigationLink(destination: AccountHistoryView(account: item.account)) {
            accountRowView
        }
    }
}
