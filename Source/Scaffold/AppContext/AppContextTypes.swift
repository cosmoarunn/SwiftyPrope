//
//  AppContextType.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation

public typealias BackgroundTaskExpirationHandler = () -> Void
public typealias AppActiveBlock = () -> Void
public typealias ReadyBlock = @MainActor () -> Void

public enum AppContextType: CaseIterable, CustomStringConvertible {
    
    case main
    case nse
    case share

    public var description: String {
        // This appears to be the default behavior but it's not actually specified by the swift documentation
        // so we make it explicit just to be sure.
        switch self {
        case .main:
            return "main"
        case .nse:
            return "nse"
        case .share:
            return "share"
        }
    }
}

/*
 UISceneActivationStateUnattached = -1,
 UISceneActivationStateForegroundActive = 0,
 UISceneActivationStateForegroundInactive = 1,
 UISceneActivationStateBackground = 2
 */
public enum SceneContextType : Int, CaseIterable, CustomStringConvertible {
    
    case unattached = -1
    case foregroundactive = 0
    case foregroundinactive = 1
    case background = 2
    
    
    public var description: String {
        
        switch self {
            
        case .unattached:
            "unattached"
        case .foregroundactive:
            "foreground active"
        case .foregroundinactive:
            "foreground inactive"
        case .background:
            "background"
        
        @unknown default:
            "unknown"
        }
    }
    
    
    
}


