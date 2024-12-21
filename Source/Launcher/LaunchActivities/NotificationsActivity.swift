//
//  ProcessNotificationActivity.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 17/12/2024.
//

import Foundation


public class NotificationsActivity : LaunchActivityTrackable {
    
    
    public var launchActivityTracker: LaunchActivityTracker?
    
    
    var startTime: CFTimeInterval?
    
    var completionTime: CFTimeInterval?
    
    var event: LaunchEvent?
    
    private var trackingEnabled: Bool = false
    
    public func launchEvent(with event: LaunchEvent) {
        self.event = event
        launchActivityTracker?.currentEvent(with: event)
        debugPrint("Notifications processing activity launched")
    }
    
    public func startTracking() {
        debugPrint("Start tracking requested")
        if !trackingEnabled  { trackingEnabled = true}
        
    }
    
    public func stopTracking() {
        debugPrint("Start tracking requested")
        trackingEnabled = false
    }
    
    public func startLaunchActivity(with completionHandler: @escaping (Result<[String:Data], Error>) throws -> Void) {
        debugPrint("Start activity requested")
        
        if trackingEnabled {
            //BenchManager.bench(title: "NotificationProcessActivity", logIfLongerThan: 0.2, logInProduction: true, block: { })
        }
        
    }
    
}

