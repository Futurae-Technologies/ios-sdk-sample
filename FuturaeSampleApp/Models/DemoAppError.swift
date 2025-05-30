//
//  SampleAppError.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 6.3.25.
//


enum SampleAppError: Error {
    case noSDKPIN
    case noBindingToken
    
    var localizedDescription: String {
        switch self {
        case .noSDKPIN:
            return "No SDK PIN provided"
        case .noBindingToken:
            return "No binding token provided"
        }
    }
}
