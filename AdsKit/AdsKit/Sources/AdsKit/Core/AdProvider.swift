//
//  AdProvider.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation
import UIKit

/// Protocol that all ad network providers must implement
/// This allows the SDK to work with any ad network in a unified way
public protocol AdProvider: AnyObject {
    /// Unique identifier for this provider (e.g., "admob")
    var identifier: String { get }
    
    /// Priority of this provider (lower number = higher priority)
    var priority: Int { get }
    
    /// Whether this provider has been successfully initialized
    var isInitialized: Bool { get }
    
    /// Initialize the ad provider
    /// - Parameters:
    ///   - completion: Called when initialization completes (success or failure)
    func initialize(completion: @escaping (Bool, Error?) -> Void)
    
    /// Load an ad of the specified type
    /// - Parameters:
    ///   - adType: The type of ad to load
    ///   - adUnitId: The ad unit ID for this ad
    ///   - completion: Called when loading completes (success or failure)
    func load(adType: AdType, adUnitId: String, completion: @escaping (Bool, Error?) -> Void)
    
    /// Check if an ad of the specified type is ready to be shown
    /// - Parameter adType: The type of ad to check
    /// - Returns: True if the ad is ready, false otherwise
    func isReady(adType: AdType) -> Bool
    
    /// Show an ad of the specified type
    /// - Parameters:
    ///   - adType: The type of ad to show
    ///   - viewController: The view controller to present the ad from
    ///   - onReward: Optional callback for rewarded ads when user earns reward
    ///   - completion: Called when showing completes (success or failure)
    func show(
        adType: AdType,
        from viewController: UIViewController,
        onReward: ((Int, String) -> Void)?,
        completion: @escaping (Bool, Error?) -> Void
    )
    
    /// Destroy/cleanup an ad of the specified type
    /// - Parameter adType: The type of ad to destroy
    func destroy(adType: AdType)
    
    /// Destroy/cleanup all ads for this provider
    func destroyAll()
}
