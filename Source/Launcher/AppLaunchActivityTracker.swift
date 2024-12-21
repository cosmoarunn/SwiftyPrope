//
//  AppLaunchActivityTracker.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 16/12/2024.
//

import Foundation


public class AppLaunchActivityTracker : LaunchActivityTracker {
   
    
    
    public static let shared = AppLaunchActivityTracker()
    
    public var launchActivityManager: LaunchActivityManager?
    
    public var startTime: CFTimeInterval?
    
    public var completionTime: CFTimeInterval?
    
    public var event: LaunchEvent?
    
    public var state: LaunchActivityState?
    
    public var errors: [launchActivityError]?
    
    public var launchAttempts: Int = 0
    
    private var appLaunchSuccess: Bool = false
    
    public init() {
        PropeSingleton.shared.register(self)
    }
    
    public func isAppLaunchSuccess() -> Bool {
        appLaunchSuccess
    }
    
    // This is the event requestd by any LaunchActivity subclass!
    public  func currentEvent(with event: LaunchEvent) {
        switch event {
            
        case .databaseMigrate:
            debugPrint("Database Migration activity starting.. (event: \(event.description))")
            PropeLog.info("Database Migration activity starting.. (event: \(event.description))")
            var activity: LaunchActivity & LaunchActivityTrackable = DBMigrateActivity()
            activity.startTracking()
            activity.launchActivityTracker = self
            activity.isRunning = true
            
            launchActivityManager?.addActivity(activity)
            
            
            debugPrint("Activity: \(activity) is added to launchActivityManager!")
            
        /*
        case .databaseVerify:  debugPrint("Current Event: \(event.description)")
        case .register: debugPrint("Current Event: \(event.description)")
        case .deviceTransfer: debugPrint("Current Event: \(event.description)")
        case .fetchUserProfile: debugPrint("Current Event: \(event.description)")
        case .fetchLocalUsersProfile: debugPrint("Current Event: \(event.description)")
        case .resetNotifications: debugPrint("Current Event: \(event.description)")
        case .downloadAttachements: debugPrint("Current Event: \(event.description)")
        case .generateThumbnailsForattachments: debugPrint("Current Event: \(event.description)")
        case .callsStateUpdate: debugPrint("Current Event: \(event.description)")
        
        }
         */
        default:
         debugPrint("Current Event: \(event.description) hasn't been implemented yet, and hence the activity may not start!")
         break
         }
    }
    
    public func start(with completionHandler: @escaping (Result<[String:Data], Error>) throws -> Void) {
        debugPrint("STARTED AppLaunchActivity \(String(describing: self.event))")
    }
    
    
    nonisolated public func stop(with completionHandler: @escaping (Result<String, any Error>) throws -> Void) {
        debugPrint("STOPPED AppLaunchActivity \(String(describing: self.event))")
        
    }
    
    
}
