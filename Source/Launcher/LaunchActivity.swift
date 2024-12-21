//
//  LaunchActivity.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 16/12/2024.
//

import Foundation
import Combine


public enum LaunchActivityPriority : Int {
    case low
    case medium
    case high
}

public enum LaunchActivityState : Int {
    case initial
    case loading
    case loaded
    case running
    case failed
    
}

public struct launchActivityError {
    let error : Error
    let state : LaunchActivityState
    
    init(error: Error, state: LaunchActivityState) {
        self.error = error
        self.state = state
    }
}

protocol Launchable {

    
    var event: LaunchEvent? { get }
    var state: LaunchActivityState? { get }
    var errors: [launchActivityError]? { get }
    
    var isRunning: Bool? { get }
    var runOnMainThread: Bool? { get }
    
    func currentEvent(with event: LaunchEvent)
    func start()
    func stop()
    
}


public class LaunchActivityManager : ObservableObject {
    @Published var launchActivities: [LaunchActivity] = []
    
    
    func addActivity(_ activity: LaunchActivity) {
        launchActivities.append(activity)
    }
    
    func listActivities() -> [LaunchActivity]  {
        return self.launchActivities
    }
    
}



public class LaunchActivity : Launchable {
    
    var event: LaunchEvent?
    var state: LaunchActivityState?
    var priority: LaunchActivityPriority?
    var errors: [launchActivityError]?
    
    var isRunning: Bool?
    var runOnMainThread: Bool?
    
    var launchActivityManager: LaunchActivityManager?
    
    func currentEvent(with event: LaunchEvent) {
        
    }
    func start() {
        
    }
    func stop() {
        
    }
}
