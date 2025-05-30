//
//  AdaptiveDebugStorage.swift
//  AdaptiveKit
//
//  Created by Armend Hasani on 31.10.22.
//

import Foundation


class AdaptiveDebugStorage: NSObject {
    private static let instance = AdaptiveDebugStorage()
    private let directoryPath = "enc-adaptive-collections"
    private let timestampKey = "timestamp"
    private let cryptoUtility = FileEncryptUtility(keychainKey: "adaptive.debug.sdk.aeskey")
    private lazy var fileUtility = FileStorageUtility(directoryPath: directoryPath, excludeFromBackup: true)
    
    public class func shared() -> AdaptiveDebugStorage {
        return instance
    }

    public func save(_ collection: [String: Any]) {
        guard let timestamp = (collection[timestampKey] as? Double)?.description else { return }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: collection)
            if let encryptedData = cryptoUtility.encrypt(data: data) {
                try fileUtility.writeFile(data: encryptedData, fileName: timestamp)
            }
            
        } catch {}
    }

    public func delete(_ collection: [String: Any]) {
        guard let timestamp = (collection[timestampKey] as? Double)?.description else { return }
        
        do {
            try fileUtility.deleteFile(fileName: timestamp)
        } catch {}
    }

    public func savedCollections() -> [[String: Any]] {
        do {
            return try fileUtility.contentsOfDirectory().compactMap { getInDirectory(withName: $0) }
        } catch {}
        
        return []
    }
    
    private func getInDirectory(withName name: String) -> [String: Any]? {
        do {
            if let data = try fileUtility.readFile(fileName: name), let decryptedData = cryptoUtility.decrypt(data: data) {
                let collection = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any]
                return collection
            }
        } catch {}
        
        return nil
    }
}
