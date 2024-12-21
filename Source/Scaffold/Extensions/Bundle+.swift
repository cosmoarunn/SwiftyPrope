//
//  Bundle+.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation

extension Bundle {
    
    private enum InfoPlistKey: String {
        case bundleIdPrefix = "PropeBundleIDPrefix"
        case merchantId = "PropeMerchantID"
    }
    
    private func infoPlistString(for key: InfoPlistKey) -> String {
        object(forInfoDictionaryKey: key.rawValue) as? String ?? String()
    }
    /// Returns the value of the PropeBundleIDPrefix from current executable's Info.plist
    /// Note: This does not parse the executable's bundleID. This only returns the value of PropeBundleIDPrefix
    /// (which the bundleID should be derived from)
    @objc
    public var bundleIdPrefix: String {
        let prefix = infoPlistString(for: Self.InfoPlistKey.bundleIdPrefix)
        if !prefix.isEmpty {
                return prefix
        } else {
            propeFailDebug("Missing Info.plist entry for PropeBundleIDPrefix")
            return "org.fgbs"
        }
    }
    
    /// Returns the value of the PropeMerchantID from current executable's Info.plist
    @objc
    public var merchantId: String {
        let prefix = infoPlistString(for: Self.InfoPlistKey.merchantId)
        if !prefix.isEmpty {
            return prefix
        } else {
            propeFailDebug("Missing Info.plist entry for PropeMerchantID")
            return "org.fgbs"
        }
    }
}
