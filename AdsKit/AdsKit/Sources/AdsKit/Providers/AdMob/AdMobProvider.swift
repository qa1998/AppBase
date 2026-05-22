//
//  AdMobProvider.swift
//  AdsKit
//
//  Created for production-ready iOS Ads SDK
//

import Foundation
import UIKit
import GoogleMobileAds

/// AdMob (Google Mobile Ads) provider implementation
public class AdMobProvider: NSObject, AdProvider, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    // MARK: - AdProvider Conformance
    
    public let identifier: String = "admob"
    public let priority: Int
    
    private var _isInitialized: Bool = false
    public var isInitialized: Bool {
        return _isInitialized
    }
    
    // MARK: - Properties
    
    /// Dictionary to track loaded ads by type
    private var loadedAds: [AdType: Bool] = [:]
    
    /// Store actual ad instances
    private var bannerViews: [AdType: GADBannerView] = [:]
    private var interstitialAds: [AdType: GADInterstitialAd] = [:]
    private var rewardedAds: [AdType: GADRewardedAd] = [:]
    private var appOpenAds: [AdType: GADAppOpenAd] = [:]
    
    /// Store completion handlers for showing ads
    private var showCompletionHandlers: [AdType: (Bool, Error?) -> Void] = [:]
    private var rewardHandlers: [AdType: (Int, String) -> Void] = [:]
    
    /// Map ad instances to ad types for delegate callbacks
    private var adInstanceToType: [String: AdType] = [:]
    
    /// Lock for thread-safe operations
    private let lockQueue = DispatchQueue(label: "com.adskit.admob", attributes: .concurrent)
    
    /// Helper to get unique identifier for ad instance
    private func getAdIdentifier(_ ad: AnyObject) -> String {
        return "\(ObjectIdentifier(ad))"
    }
    
    // MARK: - Initialization
    
    /// Initialize AdMob provider
    /// - Parameter priority: Priority of this provider (lower = higher priority)
    public init(priority: Int = 1) {
        self.priority = priority
        super.init()
    }
    
    // MARK: - AdProvider Implementation
    
    public func initialize(completion: @escaping (Bool, Error?) -> Void) {
        GADMobileAds.sharedInstance().start(completionHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?._isInitialized = true
                completion(true, nil)
            }
        })
    }
    
    public func load(adType: AdType, adUnitId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard _isInitialized else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        let request = GADRequest()
        
        switch adType {
        case .banner:
            let bannerView = GADBannerView(adSize: GADAdSizeBanner)
            bannerView.adUnitID = adUnitId
            bannerView.delegate = self
            
            lockQueue.async(flags: .barrier) {
                self.bannerViews[adType] = bannerView
            }
            
            bannerView.load(request)
            // Banner loading is asynchronous via delegate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion(true, nil)
            }
            
        case .interstitial:
            GADInterstitialAd.load(withAdUnitID: adUnitId, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    let adIdentifier = self.getAdIdentifier(ad)
                    self.lockQueue.async(flags: .barrier) {
                        self.interstitialAds[adType] = ad
                        self.adInstanceToType[adIdentifier] = adType
                        self.loadedAds[adType] = true
                    }
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                }
            }
            
        case .rewarded:
            GADRewardedAd.load(withAdUnitID: adUnitId, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    let adIdentifier = self.getAdIdentifier(ad)
                    self.lockQueue.async(flags: .barrier) {
                        self.rewardedAds[adType] = ad
                        self.adInstanceToType[adIdentifier] = adType
                        self.loadedAds[adType] = true
                    }
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                }
            }
            
        case .appOpen:
            GADAppOpenAd.load(withAdUnitID: adUnitId, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    let adIdentifier = self.getAdIdentifier(ad)
                    self.lockQueue.async(flags: .barrier) {
                        self.appOpenAds[adType] = ad
                        self.adInstanceToType[adIdentifier] = adType
                        self.loadedAds[adType] = true
                    }
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    public func isReady(adType: AdType) -> Bool {
        return lockQueue.sync {
            switch adType {
            case .banner:
                return bannerViews[adType] != nil
            case .interstitial:
                return interstitialAds[adType] != nil && loadedAds[adType] == true
            case .rewarded:
                return rewardedAds[adType] != nil && loadedAds[adType] == true
            case .appOpen:
                return appOpenAds[adType] != nil && loadedAds[adType] == true
            }
        }
    }
    
    public func show(
        adType: AdType,
        from viewController: UIViewController,
        onReward: ((Int, String) -> Void)?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard _isInitialized else {
            completion(false, AdsError.notInitialized)
            return
        }
        
        guard isReady(adType: adType) else {
            completion(false, AdsError.adNotReady)
            return
        }
        
        // Store completion handlers
        lockQueue.async(flags: .barrier) {
            self.showCompletionHandlers[adType] = completion
            if let onReward = onReward {
                self.rewardHandlers[adType] = onReward
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion(false, AdsError.notInitialized)
                return
            }
            
            switch adType {
            case .banner:
                let bannerView = self.lockQueue.sync { self.bannerViews[adType] }
                if let bannerView = bannerView {
                    bannerView.rootViewController = viewController
                    viewController.view.addSubview(bannerView)
                    // Position banner at bottom
                    bannerView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        bannerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
                        bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
                    ])
                    completion(true, nil)
                } else {
                    completion(false, AdsError.adNotReady)
                }
                
            case .interstitial:
                let interstitial = self.lockQueue.sync { self.interstitialAds[adType] }
                if let interstitial = interstitial {
                    interstitial.present(fromRootViewController: viewController)
                } else {
                    completion(false, AdsError.adNotReady)
                }
                
            case .rewarded:
                let rewardedAd = self.lockQueue.sync { self.rewardedAds[adType] }
                if let rewardedAd = rewardedAd {
                    rewardedAd.present(fromRootViewController: viewController) { [weak self] in
                        guard let self = self else { return }
                        let reward = rewardedAd.adReward
                        let handler = self.lockQueue.sync {
                            return self.rewardHandlers[adType]
                        }
                        // Call reward handler on main thread (may update UI)
                        if let handler = handler {
                            DispatchQueue.main.async {
                                handler(reward.amount.intValue, reward.type)
                            }
                        }
                    }
                } else {
                    completion(false, AdsError.adNotReady)
                }
                
            case .appOpen:
                let appOpenAd = self.lockQueue.sync { self.appOpenAds[adType] }
                if let appOpenAd = appOpenAd {
                    appOpenAd.present(fromRootViewController: viewController)
                } else {
                    completion(false, AdsError.adNotReady)
                }
            }
        }
    }
    
    public func destroy(adType: AdType) {
        // Get banner view first (if any) to remove from superview on main thread
        let bannerView = lockQueue.sync { self.bannerViews[adType] }
        
        // Remove banner view from superview on main thread (UI operation)
        if let bannerView = bannerView {
            DispatchQueue.main.async {
                bannerView.removeFromSuperview()
                bannerView.delegate = nil
            }
        }
        
        // Clean up all other data on background thread
        lockQueue.async(flags: .barrier) {
            if let interstitial = self.interstitialAds[adType] {
                self.adInstanceToType.removeValue(forKey: self.getAdIdentifier(interstitial))
            }
            if let rewarded = self.rewardedAds[adType] {
                self.adInstanceToType.removeValue(forKey: self.getAdIdentifier(rewarded))
            }
            if let appOpen = self.appOpenAds[adType] {
                self.adInstanceToType.removeValue(forKey: self.getAdIdentifier(appOpen))
            }
            self.bannerViews.removeValue(forKey: adType)
            self.interstitialAds.removeValue(forKey: adType)
            self.rewardedAds.removeValue(forKey: adType)
            self.appOpenAds.removeValue(forKey: adType)
            self.loadedAds[adType] = false
            self.showCompletionHandlers.removeValue(forKey: adType)
            self.rewardHandlers.removeValue(forKey: adType)
        }
    }
    
    public func destroyAll() {
        // Get all banner views first to remove from superview on main thread
        let allBannerViews = lockQueue.sync { Array(self.bannerViews.values) }
        
        // Remove all banner views from superview on main thread (UI operation)
        DispatchQueue.main.async {
            allBannerViews.forEach { bannerView in
                bannerView.removeFromSuperview()
                bannerView.delegate = nil
            }
        }
        
        // Clean up all other data on background thread
        lockQueue.async(flags: .barrier) {
            self.bannerViews.removeAll()
            self.interstitialAds.removeAll()
            self.rewardedAds.removeAll()
            self.appOpenAds.removeAll()
            self.adInstanceToType.removeAll()
            self.loadedAds.removeAll()
            self.showCompletionHandlers.removeAll()
            self.rewardHandlers.removeAll()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        let adIdentifier = getAdIdentifier(ad as AnyObject)
        let (adType, completion) = lockQueue.sync { () -> (AdType?, ((Bool, Error?) -> Void)?) in
            guard let type = adInstanceToType[adIdentifier] else { return (nil, nil) }
            
            let completion = showCompletionHandlers[type]
            
            // Clean up
            interstitialAds.removeValue(forKey: type)
            rewardedAds.removeValue(forKey: type)
            appOpenAds.removeValue(forKey: type)
            adInstanceToType.removeValue(forKey: adIdentifier)
            loadedAds[type] = false
            showCompletionHandlers.removeValue(forKey: type)
            rewardHandlers.removeValue(forKey: type)
            
            return (type, completion)
        }
        
        // Call completion on main thread (may update UI)
        if let completion = completion {
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        let adIdentifier = getAdIdentifier(ad as AnyObject)
        let (adType, completion) = lockQueue.sync { () -> (AdType?, ((Bool, Error?) -> Void)?) in
            guard let type = adInstanceToType[adIdentifier] else { return (nil, nil) }
            
            let completion = showCompletionHandlers[type]
            
            // Clean up
            showCompletionHandlers.removeValue(forKey: type)
            rewardHandlers.removeValue(forKey: type)
            adInstanceToType.removeValue(forKey: adIdentifier)
            
            return (type, completion)
        }
        
        // Call completion on main thread (may update UI)
        if let completion = completion {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Banner loaded successfully
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        // Banner failed to load
    }
}
