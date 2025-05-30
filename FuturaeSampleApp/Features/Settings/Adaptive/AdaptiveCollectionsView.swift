//
//  AdaptiveCollectionsView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 7.3.25.
//

import SwiftUI
import FuturaeKit

struct AdaptiveCollection: Identifiable {
    var id: String { timestamp }
    let timestamp: String
    let status: String
    let text: String
}

struct AdaptiveCollectionsView: View {
    var collections: [AdaptiveCollection] = []
    @State private var selectedCollection: AdaptiveCollection?

    init() {
        let pendingCollections = FuturaeService.client.pendingAdaptiveCollections
        collections = AdaptiveDebugStorage.shared()
            .savedCollections()
            .sorted(by: {
                if let timestamp1 = $0["timestamp"] as? Double, let timestamp2 = $1["timestamp"] as? Double {
                    return timestamp1 > timestamp2
                }
                
                return true
            })
            .compactMap {
                labelsForCollection($0, pendingCollections: pendingCollections)
            }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: String.adaptiveCollections, dismissType: .back, titleFont: .header5, paddingBottom: 12)
            if collections.isEmpty {
                Text("Collections List is Empty")
                    .font(.headline)
                    .frame(maxHeight: .infinity)
            } else {
                List(collections) { collection in
                    Button {
                        selectedCollection = collection
                    } label: {
                        HStack {
                            Text(collection.timestamp)
                            Spacer()
                            Text(collection.status)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedCollection) {
            TextDetailView(title: String.adaptiveCollectionDetail, text: $0.text)
        }
    }
    
    func labelsForCollection(_ collection: [String: Any], pendingCollections: [[String: Any]]) -> AdaptiveCollection? {
        if let timestamp = collection["timestamp"] as? Double {
            let date = Date(timeIntervalSince1970: timestamp).description
            var status = "UPLOADED"
            if let _ = (pendingCollections.first { $0["timestamp"] as? Double == timestamp }) {
                status = "PENDING"
            }
            
            var text = ""
            if let data = try? JSONSerialization.data(withJSONObject: collection, options: .prettyPrinted) {
                text = String(data: data, encoding: .utf8) ?? ""
            }
            
            return .init(timestamp: date, status: status, text: text)
        }
        
        return nil
    }
}
