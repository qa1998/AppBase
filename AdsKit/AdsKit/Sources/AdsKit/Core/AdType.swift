//
//  AdType.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation

/// Supported ad types in the SDK
public enum AdType: String, CaseIterable {
    case banner
    case interstitial
    case rewarded
    case appOpen
    
    /// Human-readable description of the ad type
    public var description: String {
        switch self {
        case .banner:
            return "Banner Ad"
        case .interstitial:
            return "Interstitial Ad"
        case .rewarded:
            return "Rewarded Ad"
        case .appOpen:
            return "App Open Ad"
        }
    }
}
