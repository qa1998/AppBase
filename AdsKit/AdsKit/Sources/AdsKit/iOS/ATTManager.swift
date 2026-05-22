//
//  ATTManager.swift
//  AdsKit
//
//  Internal helper for App Tracking Transparency (ATT)
//  Not exposed as public API; apps should use AdsManager wrappers instead.
//

import Foundation
import AdSupport

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// Tracking authorization status (compatible with iOS 13+)
public enum TrackingAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
    
    @available(iOS 14, *)
    init(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        @unknown default:
            self = .notDetermined
        }
    }
}

/// Manages App Tracking Transparency (ATT) requests
/// Safe for iOS 14+ (checks availability before using)
/// Internal to AdsKit; apps should not use this directly.
final class ATTManager {
    
    // MARK: - Properties
    
    /// Whether ATT is available (iOS 14+)
    static var isATTAvailable: Bool {
        if #available(iOS 14, *) {
            return true
        }
        return false
    }
    
    /// Current tracking authorization status
    static var trackingAuthorizationStatus: TrackingAuthorizationStatus {
        if #available(iOS 14, *) {
            #if canImport(AppTrackingTransparency)
            return TrackingAuthorizationStatus(ATTrackingManager.trackingAuthorizationStatus)
            #else
            return .authorized
            #endif
        }
        // For iOS < 14, assume authorized (legacy behavior)
        return .authorized
    }
    
    // MARK: - Methods
    
    /// Request tracking authorization from the user
    /// Only works on iOS 14+
    /// - Parameter completion: Called with the authorization status
    static func requestTrackingAuthorization(completion: @escaping (TrackingAuthorizationStatus) -> Void) {
        if #available(iOS 14, *) {
            #if canImport(AppTrackingTransparency)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    completion(TrackingAuthorizationStatus(status))
                }
            }
            #else
            completion(.authorized)
            #endif
        } else {
            // iOS < 14: No ATT required, assume authorized
            completion(.authorized)
        }
    }
    
    /// Check if tracking is authorized
    /// - Returns: True if authorized, false otherwise
    static func isTrackingAuthorized() -> Bool {
        return trackingAuthorizationStatus == .authorized
    }
    
    /// Get the advertising identifier (IDFA)
    /// Returns nil if tracking is not authorized
    /// - Returns: The IDFA string, or nil if not available
    static func getIDFA() -> String? {
        if #available(iOS 14, *) {
            guard trackingAuthorizationStatus == .authorized else {
                return nil
            }
        }
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        if idfa.uuidString == "00000000-0000-0000-0000-000000000000" {
            return nil
        }
        return idfa.uuidString
    }
    
    /// Request tracking authorization if needed
    /// This is a convenience method that checks status first
    /// - Parameter completion: Called with whether tracking is now authorized
    static func requestIfNeeded(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            let currentStatus = trackingAuthorizationStatus
            if currentStatus == .notDetermined {
                requestTrackingAuthorization { status in
                    completion(status == .authorized)
                }
            } else {
                completion(currentStatus == .authorized)
            }
        } else {
            completion(true)
        }
    }
}

