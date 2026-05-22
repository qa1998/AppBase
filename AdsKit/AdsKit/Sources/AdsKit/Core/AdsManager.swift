//
//  AdsManager.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation
import UIKit

/// Main public API for the Ads SDK
/// This is the only class the app should interact with
public class AdsManager {
    
    // MARK: - Singleton
    
    /// Shared singleton instance
    @MainActor public static let shared = AdsManager()
    
    // MARK: - Properties
    
    /// Router that handles provider selection and fallback
    private let router = AdsRouter()
    
    /// Configuration for ad unit IDs and provider priority
    private var config: AdsConfig?
    
    /// Whether the SDK has been initialized
    private var isInitialized = false
    
    /// Lock for thread-safe initialization
    private let initLock = NSLock()
    
    /// Currently showing ad type (nil if no ad is showing)
    /// Used to prevent multiple ads from showing simultaneously
    private var currentlyShowingAdType: AdType?
    
    /// Lock for thread-safe ad showing
    private let showingLock = NSLock()
    
    /// Whether ads are enabled (default: true)
    /// When disabled, all load/show operations will fail with adsDisabled error
    private var _adsEnabled: Bool = true
    
    /// Lock for thread-safe ads enabled state
    private let enabledLock = NSLock()
    
    // MARK: - Initialization
    
    private init() {}
    
    /// Initialize the Ads SDK
    /// - Parameters:
    ///   - config: Configuration containing ad unit IDs and provider priority
    ///   - providers: Array of ad providers to register
    ///   - completion: Called when initialization completes
    public func initialize(
        config: AdsConfig,
        providers: [AdProvider],
        completion: @escaping (Bool, Error?) -> Void
    ) {
        initLock.lock()
        defer { initLock.unlock() }
        
        guard !isInitialized else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        self.config = config
        
        // Register all providers
        providers.forEach { router.registerProvider($0) }
        
        // Initialize all providers
        let providerGroup = DispatchGroup()
        var initializationErrors: [String: Error] = [:]
        
        for provider in providers {
            providerGroup.enter()
            provider.initialize { [weak self] success, error in
                if !success, let error = error {
                    initializationErrors[provider.identifier] = error
                }
                providerGroup.leave()
            }
        }
        
        providerGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.isInitialized = true
            
            if initializationErrors.isEmpty {
                completion(true, nil)
            } else {
                // Still mark as initialized if at least one provider succeeded
                let errorMessage = initializationErrors.map { "\($0.key): \($0.value.localizedDescription)" }.joined(separator: "; ")
                completion(true, AdsError.providerInitializationFailed(errorMessage))
            }
        }
    }
    
    // MARK: - Ads Enable/Disable
    
    /// Enable or disable ads
    /// When disabled, all load/show operations will fail with adsDisabled error
    /// - Parameter enabled: Whether to enable ads (default: true)
    public func setAdsEnabled(_ enabled: Bool) {
        enabledLock.lock()
        _adsEnabled = enabled
        enabledLock.unlock()
        
        if !enabled {
            // Destroy all ads when disabling
            destroyAll()
        }
    }
    
    /// Check if ads are currently enabled
    /// - Returns: True if ads are enabled, false otherwise
    public func isAdsEnabled() -> Bool {
        enabledLock.lock()
        defer { enabledLock.unlock() }
        return _adsEnabled
    }
    
    // MARK: - Public API
    // MARK: - App Tracking Transparency (ATT)

    /// Request tracking authorization if needed (iOS 13+)
    /// This checks current status and only shows the ATT dialog if required.
    /// - Parameter completion: Called with whether tracking is now authorized.
    public func requestTrackingAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        ATTManager.requestIfNeeded(completion: completion)
    }

    /// Get current ATT tracking authorization status.
    public func trackingAuthorizationStatus() -> TrackingAuthorizationStatus {
        return ATTManager.trackingAuthorizationStatus
    }

    /// Get the advertising identifier (IDFA) if available.
    /// Returns nil if tracking is not authorized or IDFA is unavailable.
    public func advertisingIdentifier() -> String? {
        return ATTManager.getIDFA()
    }

    
    /// Load a banner ad
    /// - Parameter completion: Called when loading completes
    public func loadBanner(completion: @escaping (Bool, Error?) -> Void) {
        guard isAdsEnabled() else {
            completion(false, AdsError.adsDisabled)
            return
        }
        
        guard isInitialized, let config = config else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        guard let adUnitId = config.getAdUnitId(for: .banner) else {
            completion(false, AdsError.invalidAdUnitId(.banner))
            return
        }
        
        router.loadAd(adType: .banner, adUnitId: adUnitId, completion: completion)
    }
    
    /// Load an interstitial ad
    /// - Parameter completion: Called when loading completes
    public func loadInterstitial(completion: @escaping (Bool, Error?) -> Void) {
        guard isAdsEnabled() else {
            completion(false, AdsError.adsDisabled)
            return
        }
        
        guard isInitialized, let config = config else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        guard let adUnitId = config.getAdUnitId(for: .interstitial) else {
            completion(false, AdsError.invalidAdUnitId(.interstitial))
            return
        }
        
        router.loadAd(adType: .interstitial, adUnitId: adUnitId, completion: completion)
    }
    
    /// Load a rewarded ad
    /// - Parameter completion: Called when loading completes
    public func loadRewarded(completion: @escaping (Bool, Error?) -> Void) {
        guard isAdsEnabled() else {
            completion(false, AdsError.adsDisabled)
            return
        }
        
        guard isInitialized, let config = config else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        guard let adUnitId = config.getAdUnitId(for: .rewarded) else {
            completion(false, AdsError.invalidAdUnitId(.rewarded))
            return
        }
        
        router.loadAd(adType: .rewarded, adUnitId: adUnitId, completion: completion)
    }
    
    /// Load an app open ad
    /// - Parameter completion: Called when loading completes
    public func loadAppOpen(completion: @escaping (Bool, Error?) -> Void) {
        guard isAdsEnabled() else {
            completion(false, AdsError.adsDisabled)
            return
        }
        
        guard isInitialized, let config = config else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        guard let adUnitId = config.getAdUnitId(for: .appOpen) else {
            completion(false, AdsError.invalidAdUnitId(.appOpen))
            return
        }
        
        router.loadAd(adType: .appOpen, adUnitId: adUnitId, completion: completion)
    }
    
    /// Check if a banner ad is ready
    /// - Returns: True if ready, false otherwise
    public func isBannerReady() -> Bool {
        return router.isAdReady(adType: .banner)
    }
    
    /// Check if an interstitial ad is ready
    /// - Returns: True if ready, false otherwise
    public func isInterstitialReady() -> Bool {
        return router.isAdReady(adType: .interstitial)
    }
    
    /// Check if a rewarded ad is ready
    /// - Returns: True if ready, false otherwise
    public func isRewardedReady() -> Bool {
        return router.isAdReady(adType: .rewarded)
    }
    
    /// Check if an app open ad is ready
    /// - Returns: True if ready, false otherwise
    public func isAppOpenReady() -> Bool {
        return router.isAdReady(adType: .appOpen)
    }
    
    /// Show a banner ad
    /// - Parameters:
    ///   - viewController: The view controller to present from
    ///   - completion: Called when showing completes
    public func showBanner(
        from viewController: UIViewController,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        showAd(adType: .banner, from: viewController, onReward: nil, completion: completion)
    }
    
    /// Show an interstitial ad
    /// - Parameters:
    ///   - viewController: The view controller to present from
    ///   - completion: Called when showing completes
    public func showInterstitial(
        from viewController: UIViewController,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        showAd(adType: .interstitial, from: viewController, onReward: nil, completion: completion)
    }
    
    /// Show a rewarded ad
    /// - Parameters:
    ///   - viewController: The view controller to present from
    ///   - completion: Called when showing completes
    public func showRewarded(
        from viewController: UIViewController,
        onReward: @escaping (Int, String) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        showAd(adType: .rewarded, from: viewController, onReward: onReward, completion: completion)
    }
    
    /// Show an app open ad
    /// - Parameters:
    ///   - viewController: The view controller to present from
    ///   - completion: Called when showing completes
    public func showAppOpen(
        from viewController: UIViewController,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        showAd(adType: .appOpen, from: viewController, onReward: nil, completion: completion)
    }
    
    /// Internal method to show an ad with safety checks
    private func showAd(
        adType: AdType,
        from viewController: UIViewController,
        onReward: ((Int, String) -> Void)?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard isAdsEnabled() else {
            completion(false, AdsError.adsDisabled)
            return
        }
        
        guard isInitialized else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        // Prevent multiple ads from showing at the same time
        showingLock.lock()
        if currentlyShowingAdType != nil {
            showingLock.unlock()
            completion(false, AdsError.adAlreadyShowing)
            return
        }
        currentlyShowingAdType = adType
        showingLock.unlock()
        
        // Check if ad is ready
        guard router.isAdReady(adType: adType) else {
            showingLock.lock()
            currentlyShowingAdType = nil
            showingLock.unlock()
            completion(false, AdsError.adNotReady)
            return
        }
        
        // Show the ad
        router.showAd(
            adType: adType,
            from: viewController,
            onReward: onReward
        ) { [weak self] success, error in
            // Clear the currently showing ad type
            self?.showingLock.lock()
            self?.currentlyShowingAdType = nil
            self?.showingLock.unlock()
            
            completion(success, error)
        }
    }
    
    /// Destroy a specific ad type
    /// - Parameter adType: The type of ad to destroy
    public func destroy(adType: AdType) {
        router.destroyAd(adType: adType)
    }
    
    /// Destroy all ads
    public func destroyAll() {
        router.destroyAllAds()
    }
}
