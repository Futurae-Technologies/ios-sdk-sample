//
//  ActivityRowView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//


import SwiftUI
import FuturaeKit

struct ActivityRowView: View {
    let activity: AccountActivityItem
    
    var body: some View {
        let image = Image(activity.image)
            .accessibilityIdentifier(activity.isSuccess ? "account_history_success" : "account_history_failure")
    
        HStack(spacing: 12) {
            image
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.header5)
                    .foregroundColor(Color.textDark)
                
                HStack(spacing: 8) {
                    Text(activity.date, style: .date)
                        .font(.bodySmall)
                        .foregroundColor(Color.textAlt)
                        
                    Text(activity.date, style: .time)
                        .font(.bodySmall)
                        .foregroundColor(Color.textAlt)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
