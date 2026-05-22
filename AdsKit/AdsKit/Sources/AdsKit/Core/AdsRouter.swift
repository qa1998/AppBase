//
//  AdsRouter.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation
import UIKit

/// Routes ad requests to the appropriate provider based on priority and readiness
/// Handles fallback logic when a provider fails or is not ready
internal class AdsRouter {
    
    // MARK: - Properties
    
    /// List of registered ad providers, sorted by priority
    private var providers: [AdProvider] = []
    
    /// Lock for thread-safe access
    private let lockQueue = DispatchQueue(label: "com.adskit.router", attributes: .concurrent)
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Provider Management
    
    /// Register an ad provider
    /// - Parameter provider: The provider to register
    func registerProvider(_ provider: AdProvider) {
        lockQueue.async(flags: .barrier) {
            // Remove if already exists
            self.providers.removeAll { $0.identifier == provider.identifier }
            // Add new provider
            self.providers.append(provider)
            // Sort by priority (lower number = higher priority)
            self.providers.sort { $0.priority < $1.priority }
        }
    }
    
    /// Unregister an ad provider
    /// - Parameter identifier: The identifier of the provider to remove
    func unregisterProvider(identifier: String) {
        lockQueue.async(flags: .barrier) {
            self.providers.removeAll { $0.identifier == identifier }
        }
    }
    
    /// Get all registered providers
    /// - Returns: Array of providers sorted by priority
    func getAllProviders() -> [AdProvider] {
        return lockQueue.sync {
            return providers
        }
    }
    
    // MARK: - Provider Selection
    
    /// Find the first available provider for the given ad type
    /// A provider is available if it's initialized and has a ready ad
    /// - Parameter adType: The type of ad needed
    /// - Returns: The first available provider, or nil if none are available
    func findAvailableProvider(for adType: AdType) -> AdProvider? {
        return lockQueue.sync {
            // Return first provider that is initialized and has a ready ad
            return providers.first { provider in
                provider.isInitialized && provider.isReady(adType: adType)
            }
        }
    }
    
    /// Get all initialized providers for the given ad type, sorted by priority
    /// - Parameter adType: The type of ad needed
    /// - Returns: Array of initialized providers
    func getInitializedProviders(for adType: AdType) -> [AdProvider] {
        return lockQueue.sync {
            return providers.filter { $0.isInitialized }
        }
    }
    
    // MARK: - Ad Operations
    
    /// Load an ad using the first available provider (by priority)
    /// - Parameters:
    ///   - adType: The type of ad to load
    ///   - adUnitId: The ad unit ID
    ///   - completion: Called when loading completes
    func loadAd(adType: AdType, adUnitId: String, completion: @escaping (Bool, Error?) -> Void) {
        let providers = getInitializedProviders(for: adType)
        
        guard !providers.isEmpty else {
            completion(false, AdsError.noProviderAvailable)
            return
        }
        
        // Try to load with the highest priority provider first
        tryLoadWithProvider(providers: providers, index: 0, adType: adType, adUnitId: adUnitId, completion: completion)
    }
    
    /// Recursively try loading with providers until one succeeds
    private func tryLoadWithProvider(
        providers: [AdProvider],
        index: Int,
        adType: AdType,
        adUnitId: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard index < providers.count else {
            // All providers failed
            completion(false, AdsError.failedToLoad("All providers failed to load"))
            return
        }
        
        let provider = providers[index]
        provider.load(adType: adType, adUnitId: adUnitId) { [weak self] success, error in
            if success {
                completion(true, nil)
            } else {
                // Try next provider
                self?.tryLoadWithProvider(
                    providers: providers,
                    index: index + 1,
                    adType: adType,
                    adUnitId: adUnitId,
                    completion: completion
                )
            }
        }
    }
    
    /// Show an ad using the first ready provider
    /// - Parameters:
    ///   - adType: The type of ad to show
    ///   - viewController: The view controller to present from
    ///   - onReward: Optional reward callback
    ///   - completion: Called when showing completes
    func showAd(
        adType: AdType,
        from viewController: UIViewController,
        onReward: ((Int, String) -> Void)?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard let provider = findAvailableProvider(for: adType) else {
            completion(false, AdsError.adNotReady)
            return
        }
        
        provider.show(
            adType: adType,
            from: viewController,
            onReward: onReward,
            completion: completion
        )
    }
    
    /// Check if any provider has a ready ad
    /// - Parameter adType: The type of ad to check
    /// - Returns: True if any provider has a ready ad
    func isAdReady(adType: AdType) -> Bool {
        return findAvailableProvider(for: adType) != nil
    }
    
    /// Destroy an ad of the specified type across all providers
    /// - Parameter adType: The type of ad to destroy
    func destroyAd(adType: AdType) {
        let providers = getAllProviders()
        providers.forEach { $0.destroy(adType: adType) }
    }
    
    /// Destroy all ads across all providers
    func destroyAllAds() {
        let providers = getAllProviders()
        providers.forEach { $0.destroyAll() }
    }
}
