//
//  AppDelegate.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//

import UIKit
import AdsKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAdsKit()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - AdsKit Configuration
    
    func setupAdsKit() {
        // Create ad unit IDs configuration
        // TODO: Replace with your actual AdMob ad unit IDs
        let adsConfig = AdsConfig(
            banner: "ca-app-pub-3940256099942544/2934735716", // Test banner ad unit ID
            interstitial: "ca-app-pub-3940256099942544/4411468910", // Test interstitial ad unit ID
            rewarded: "ca-app-pub-3940256099942544/1712485313", // Test rewarded ad unit ID
            appOpen: "ca-app-pub-3940256099942544/5662855259" // Test app open ad unit ID
        )
        
        // Create AdMob provider
        let adMobProvider = AdMobProvider(priority: 1)
        
        // Initialize AdsKit
        AdsManager.shared.initialize(
            config: adsConfig,
            providers: [adMobProvider]
        ) { success, error in
            if success {
                print("✅ AdsKit initialized successfully")
                if let error = error {
                    print("⚠️ Some providers failed to initialize: \(error.localizedDescription)")
                }
                
                // Request App Tracking Transparency (iOS 14+)
                self.requestTrackingAuthorization()
            } else {
                print("❌ AdsKit initialization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func requestTrackingAuthorization() {
        // Request ATT permission for better ad targeting via AdsKit wrapper
        AdsManager.shared.requestTrackingAuthorizationIfNeeded { authorized in
            if authorized {
                print("✅ Tracking authorized")
                if let idfa = AdsManager.shared.advertisingIdentifier() {
                    print("📱 IDFA: \(idfa)")
                }
            } else {
                print("⚠️ Tracking not authorized")
            }
        }
    }
}

