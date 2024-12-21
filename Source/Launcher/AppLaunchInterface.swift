//
//  AppLaunchInterface.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import SwiftUICore

public enum AppLaunchStatus: Int, CaseIterable {
    case initializing
    case ready
    case failed
}

public enum AppLaunchInterface {
    case registraton
    case primaryRequisites
    case secondaryProvisioning
    case conversationList
    case propeRadar
}


public enum LaunchEvent : Int, CaseIterable  {
    case register
    case deviceTransfer
    case databaseVerify
    case databaseMigrate
    case fetchUserProfile
    case fetchLocalUsersProfile
    case resetNotifications
    case downloadAttachements
    case generateThumbnailsForattachments
    case callsStateUpdate
    
    var description : String {
        switch self {
            case .register: "Register"
            case .deviceTransfer: "Device Transfer"
            case .databaseVerify: "Database Verify"
            case .databaseMigrate: "Database Migrate"
            case .fetchUserProfile: "Fetch User Profile"
            case .fetchLocalUsersProfile: "Fetch Local Users Profile"
            case .resetNotifications: "Reset Notifications"
            case .downloadAttachements: "Download Attachements"
            case .generateThumbnailsForattachments: "Generate Thumbnails For Attachments"
            case .callsStateUpdate: "Calls State Update"
        }
    }
}



public protocol LaunchActivityTrackable {  //Coordinatable
    var launchActivityTracker : LaunchActivityTracker? { get  set }
    
    func launchEvent(with event : LaunchEvent) 
    func startTracking()
    func stopTracking()
    func startLaunchActivity(with completionHandler: @escaping (Result<[String:Data], Error>) throws -> Void)
}


public protocol LaunchActivityTracker {  //Cooridnator
    
    var launchActivityManager: LaunchActivityManager? { get set } //like a navcontroller for example
    
    var startTime: CFTimeInterval? { get set }
    
    var completionTime: CFTimeInterval? { get set }
    
    var event: LaunchEvent? { get set }
    
    var state: LaunchActivityState? { get set }
    
    var errors: [launchActivityError]? { get set }
    
    func currentEvent(with event: LaunchEvent)
    
    func start(with completionHandler: @escaping (Result<[String:Data], Error>) throws -> Void)
    
    func stop(with completionHandler: @escaping (Result<String, any Error>) throws -> Void)
    
}



enum LaunchErrorTypes: Int, CaseIterable {
    case obsoleteDatabaseVersionError
    case failedToUpdateReceivedDataError
    case dbCorruptedYetRecoverableError
    case dbIrrecoverableError
    case prevAppLaunchCrashedError
    case storageSpaceLowError
    
    
    var description: String {
        switch self {
            case .obsoleteDatabaseVersionError: return "LaunchFail_ObsoleteDatabaseVersionError"
            case .failedToUpdateReceivedDataError: return "LaunchFail_FailedToUpdateReceivedDataError"
            case .dbCorruptedYetRecoverableError: return "LaunchFail_DatabaseCorruptedYetRecoverableError"
            case .dbIrrecoverableError: return "LaunchFail_DatabaseIrrecoverableError"
            case .prevAppLaunchCrashedError: return "LaunchFail_PreviouseAppLaunchCrashedErrorError"
            case .storageSpaceLowError: return "LaunchFail_DiskStorageSpaceLowError"
        }
    }
    
}
