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
        HStack(spacing: 12) {
            Image(activity.image)
            
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
