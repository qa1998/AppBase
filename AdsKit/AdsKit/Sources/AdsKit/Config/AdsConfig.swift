//
//  AdsConfig.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation

/// Configuration for ad unit IDs and provider settings
public class AdsConfig {
    
    // MARK: - Properties
    
    /// Dictionary mapping ad types to their ad unit IDs
    /// Key: AdType, Value: Ad unit ID string
    private var adUnitIds: [AdType: String] = [:]
    
    // MARK: - Initialization
    
    /// Initialize with ad unit IDs for each ad type
    /// - Parameter adUnitIds: Dictionary mapping ad types to ad unit IDs
    public init(adUnitIds: [AdType: String]) {
        self.adUnitIds = adUnitIds
    }
    
    /// Convenience initializer for setting ad unit IDs individually
    public init(
        banner: String? = nil,
        interstitial: String? = nil,
        rewarded: String? = nil,
        appOpen: String? = nil
    ) {
        if let banner = banner {
            adUnitIds[.banner] = banner
        }
        if let interstitial = interstitial {
            adUnitIds[.interstitial] = interstitial
        }
        if let rewarded = rewarded {
            adUnitIds[.rewarded] = rewarded
        }
        if let appOpen = appOpen {
            adUnitIds[.appOpen] = appOpen
        }
    }
    
    // MARK: - Public Methods
    
    /// Get the ad unit ID for a specific ad type
    /// - Parameter adType: The type of ad
    /// - Returns: The ad unit ID, or nil if not configured
    public func getAdUnitId(for adType: AdType) -> String? {
        return adUnitIds[adType]
    }
    
    /// Set the ad unit ID for a specific ad type
    /// - Parameters:
    ///   - adUnitId: The ad unit ID
    ///   - adType: The type of ad
    public func setAdUnitId(_ adUnitId: String, for adType: AdType) {
        adUnitIds[adType] = adUnitId
    }
    
    /// Check if an ad unit ID is configured for a specific ad type
    /// - Parameter adType: The type of ad
    /// - Returns: True if configured, false otherwise
    public func hasAdUnitId(for adType: AdType) -> Bool {
        return adUnitIds[adType] != nil
    }
}
