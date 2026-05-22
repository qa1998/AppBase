//
//  AdsError.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation

/// Errors that can occur during ad operations
public enum AdsError: Error, LocalizedError {
    case notInitialized
    case noProviderAvailable
    case adNotReady
    case adAlreadyShowing
    case failedToLoad(String)
    case failedToShow(String)
    case invalidAdUnitId(AdType)
    case providerInitializationFailed(String)
    case adsDisabled
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Ads SDK has not been initialized"
        case .noProviderAvailable:
            return "No ad provider is available for this ad type"
        case .adNotReady:
            return "Ad is not ready to be shown"
        case .adAlreadyShowing:
            return "An ad is already being displayed"
        case .failedToLoad(let reason):
            return "Failed to load ad: \(reason)"
        case .failedToShow(let reason):
            return "Failed to show ad: \(reason)"
        case .invalidAdUnitId(let adType):
            return "Invalid ad unit ID for \(adType.description)"
        case .providerInitializationFailed(let provider):
            return "Failed to initialize provider: \(provider)"
        case .adsDisabled:
            return "Ads are currently disabled"
        }
    }
}
