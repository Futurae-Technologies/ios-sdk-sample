//
//  UsernamelessAccountSelectorView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct UsernamelessAccountSelectorView: View {
    let onAccountSelected: (String) -> Void
    
    @State private var accounts: [FTRAccount] = []
    @State private var selectedUserId: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(title: String.selectAccountPrompt, image: ImageAsset.selectAccount, dismissType: .close)
                
                if accounts.isEmpty {
                    Spacer()
                    Text(String.accountsListIsEmpty)
                        .foregroundColor(.secondary)
                } else {
                    List(accounts, id: \.userId) { account in
                        accountRowView(account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedUserId = account.userId
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
                
                RoundedButton(title: String.authenticate, icon: nil, action: {
                    if let userId = selectedUserId {
                        onAccountSelected(userId)
                    }
                }, style: selectedUserId != nil ? .primary : .disabled, isFullWidth: true)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                loadAccounts()
            }
        }
    }
    
    func accountRowView(_ item: FTRAccount) -> some View {
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
                if let serviceName = item.serviceName {
                    Text(serviceName)
                        .font(.header4)
                        .foregroundColor(Color.textDark)
                }
                
                if let username = item.username {
                    Text(username)
                        .font(.bodyLarge)
                        .foregroundColor(Color.textAlt)
                }
                
            }
            .padding(.leading, 12)
            
            Spacer()
            if selectedUserId == item.userId {
                Image(ImageAsset.success)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func loadAccounts() {
        accounts = (try? FuturaeService.client.getAccounts())?.filter { !$0.lockedOut } ?? []
    }
}
