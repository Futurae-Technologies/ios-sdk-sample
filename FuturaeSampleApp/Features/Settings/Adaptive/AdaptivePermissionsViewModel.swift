//
//  AdaptivePermissionsViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 7.3.25.
//

import SwiftUI
import CoreLocation
import CoreBluetooth
import FuturaeKit
import AdaptiveKit

enum AdaptivePermission: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case bluetoothPermission = "Bluetooth Permission"
    case locationPermission = "Location Permission"
    case networkPermission = "Network Permssion"
}

final class AdaptivePermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    @Published var statuses: [AdaptivePermission: AdaptivePermissionStatus] = [:]
    @Published var permissionBeingRequested: AdaptivePermission? = nil
    
    private var locationManager: CLLocationManager?
    private var centralManager: CBCentralManager?
    private var localAuth: LocalNetworkAuthorization?
    
    override init() {
        super.init()
        for permission in AdaptivePermission.allCases {
            statuses[permission] = .unknown
        }
    }
    
    func requestPermission(for permission: AdaptivePermission) {
        permissionBeingRequested = permission
        switch permission {
        case .bluetoothPermission:
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        case .locationPermission:
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        case .networkPermission:
            localNetworkCheck()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let permission = self.permissionBeingRequested,
              permission == .locationPermission
        else { return }
        
        let adaptiveStatus: AdaptivePermissionStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            adaptiveStatus = .on
        case .denied, .restricted:
            adaptiveStatus = .off
        default:
            adaptiveStatus = .unknown
        }
        DispatchQueue.main.async {
            self.statuses[permission] = adaptiveStatus
            self.permissionBeingRequested = nil
        }
        locationManager = nil
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let permission = self.permissionBeingRequested,
              permission == .bluetoothPermission else { return }
        
        let authStatus = CBCentralManager.authorization
        let adaptiveStatus: AdaptivePermissionStatus = (authStatus == .allowedAlways) ? .on : (authStatus == .denied ? .off : .unknown)
        DispatchQueue.main.async {
            self.statuses[permission] = adaptiveStatus
            self.permissionBeingRequested = nil
        }
        centralManager = nil
    }
    
    func statusText(for permission: AdaptivePermission) -> String {
        let status = statuses[permission] ?? .unknown
        switch status {
        case .unknown: return "Unknown"
        case .on: return "On"
        case .off: return "Off"
        }
    }
    
    func checkCurrentPermissions() {
        // Location permissions
        let locStatus = CLLocationManager.authorizationStatus()
        let locAdaptiveStatus: AdaptivePermissionStatus
        switch locStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locAdaptiveStatus = .on
        case .denied, .restricted:
            locAdaptiveStatus = .off
        default:
            locAdaptiveStatus = .unknown
        }
        statuses[.locationPermission] = locAdaptiveStatus
        
        // Bluetooth permissions
        let btStatus = CBCentralManager.authorization
        let btAdaptiveStatus: AdaptivePermissionStatus = (btStatus == .allowedAlways) ? .on : (btStatus == .denied ? .off : .unknown)
        statuses[.bluetoothPermission] = btAdaptiveStatus
        
        localNetworkCheck()
    }
    
    func localNetworkCheck(){
        localAuth = LocalNetworkAuthorization()
        localAuth?.requestAuthorization { [weak self] granted in
            self?.statuses[.networkPermission] = granted ? .on : .off
        }
    }
}
