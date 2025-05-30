//
//  FloatingUnlockButton.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 6.3.25.
//


import SwiftUI
import FuturaeKit

struct FloatingUnlockButton: View {
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var sdkState: SDKState? = FuturaeService.client.sdkState
    @State var showFloatingButton = false
    @State var showUnlockScreen = false
    @State var unlockScreenHandled = true
    
    @StateObject var prefs = GlobalPreferences.shared
    
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment:.topTrailing) {
            HStack(spacing: 2) {
                let displayText = textForSDKState(sdkState)
                        
                Button(action: {
                    onTap()
                }) {
                    ZStack {
                        if displayText.isEmpty {
                            Image(systemName: "lock.open.fill")
                        } else {
                            Label(displayText, systemImage: "lock.open.fill")
                                .font(.header5)
                        }
                    }
                    .foregroundStyle(Color.neutralWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
            .background(Color.black.opacity(0.6)) //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .foregroundColor(.neutralWhite)
            .cornerRadius(8)
            .opacity(showFloatingButton ? 1 : 0)
        }
        .onReceive(timer) { _ in
            let state = FuturaeService.client.sdkState
            sdkState = state
            
            let hasUnlockMethods = !FuturaeService.client.activeUnlockMethods.filter { $0 != .none }.isEmpty
            if unlockScreenHandled && prefs.unlockScreenWhenLocked && state.lockStatus == .locked && hasUnlockMethods {
                showUnlockScreen = true
                unlockScreenHandled = false
            }
            
            showFloatingButton = prefs.floatingButton && hasUnlockMethods
        }
        .fullScreenCover(isPresented: $showUnlockScreen){
            SDKUnlockView(onUnlocked: {
                self.showUnlockScreen = false
                self.unlockScreenHandled = true
            }, callback: { self.showUnlockScreen = false })
        }
    }
    
    private func textForSDKState(_ state: SDKState?) -> String {
        guard let state = state else { return "" }
        if state.lockStatus == .unlocked {
            let remaining = Int(state.unlockedRemainingDuration)
            return "\(remaining)s"
        } else {
            return ""
        }
    }
}
