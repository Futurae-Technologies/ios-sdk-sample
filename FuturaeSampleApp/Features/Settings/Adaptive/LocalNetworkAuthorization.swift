//
//  LocalNetworkAuthorization.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 20.11.25.
//


import Foundation
import Network
import dnssd // for kDNSServiceErr_PolicyDenied

/// Helper that requests Local Network authorization and reports the result.
/// It triggers the system alert if needed, and waits for network callbacks
final class LocalNetworkAuthorization: NSObject {

    private var browser: NWBrowser?
    private var listener: NWListener?
    private var completion: ((Bool) -> Void)?
    private let queue = DispatchQueue(label: "local-network-authorization")

    /// Requests local network authorization (if not determined yet) and
    /// reports `true` when permission is granted, `false` when denied.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion

        let type = "_airplay._tcp." // must be one any of the listed entries in NSBonjourServices in Info.plist

        do {
            // 1) Listener that advertises a Bonjour service on localhost.
            let params = NWParameters.tcp
            let listener = try NWListener(using: params)
            listener.service = NWListener.Service(
                name: UUID().uuidString,
                type: type
            )
            listener.newConnectionHandler = { connection in
                // We don't actually need to talk, just accept and close.
                connection.cancel()
            }
            listener.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }
                if case .failed = state {
                    // If the listener fails for some reason that isn't policy,
                    // we treat it as "no permission".
                    self.finish(granted: false)
                }
            }
            self.listener = listener

            // 2) Browser that looks for that service.
            let browserParams = NWParameters()
            browserParams.includePeerToPeer = true
            let browser = NWBrowser(
                for: .bonjour(type: type, domain: nil),
                using: browserParams
            )
            self.browser = browser

            browser.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .waiting(let error), .failed(let error):
                    if case let .dns(dnsError) = error,
                       dnsError == kDNSServiceErr_PolicyDenied {
                        // Local Network permission explicitly denied.
                        self.finish(granted: false)
                    }
                default:
                    break
                }
            }
            

            browser.browseResultsChangedHandler = { [weak self] results, changes in
                guard let self = self, let service = listener.service else { return }

                // If the browser discovers our own listener service,
                // we know Local Network access is granted.
                let granted = results.contains {
                    switch $0.endpoint {
                        
                    case .service(let name, _, _, _):
                        if name == service.name {
                            return true
                        }
                    default:
                        break
                    }
                    
                    return false
                }

                if granted {
                    self.finish(granted: true)
                }
            }

            listener.start(queue: queue)
            browser.start(queue: queue)

        } catch {
            // Could not start browser/listener – treat as "no permission".
            completion(false)
            self.completion = nil
        }
    }

    private func finish(granted: Bool) {
        browser?.cancel()
        listener?.cancel()
        browser = nil
        listener = nil

        let completion = self.completion
        self.completion = nil

        DispatchQueue.main.async {
            completion?(granted)
        }
    }

    deinit {
        browser?.cancel()
        listener?.cancel()
    }
}