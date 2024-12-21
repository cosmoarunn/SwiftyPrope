//
//  PropeBGTask.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 17/12/2024.
//

import Foundation
import BackgroundTasks
import Synchronization
import UIKit
 
public enum PropeTaskState {
    case scheduled
    case notStarted
    case suspended
    case running
    case expired
    case failed
}

public typealias Key = String
public typealias Resource = Any


@available(iOS 18.0, *)
public struct PropeBGTaskManagerExt : ~Copyable {
    private let cache = Mutex<[Key: Resource]>([:])
    
    ////MARK : @TODO:  extension for ios 18.0 or newer
}

//com.fgbs.PAndE

public class PropeBGTaskManager {
    
    private let lock = NSRecursiveLock()
    
    public static let shared =  {
        Thread.isMainThread ?  PropeBGTaskManager() : DispatchQueue.main.sync { PropeBGTaskManager() }
    }
    /// These following properties  should only be accessed using a `lock` unless otherwise they aere Mutex.
    private var tasks: [PropeBackgroundTask] = []
    private var currentbackgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var taskExpirationRoutines: [UInt64 : @Sendable () -> Void] = [:]
    private var taskCount: UInt64 = 0
    
    private var isAppActive: Bool = PropeAppContext().isMainAppAndActive
    private var didBecomeActiveObserver: (any NSObjectProtocol)?
    private var willResignActiveObserver: (any NSObjectProtocol)?
    
    private var allTasksExpired:Bool = false
    ///when one task end before another begins, a bg task fills up the gap
    private var taskChainTimer: Timer?
    
    
    private init() {
        AssertIsOnMainThread()
        //PropeSingleton.shared.register(self)
       
    }
    
    deinit {
        lock.withLock {
            self.clearObservers()
        }
    }
    

    
    public func registerTask(_ expirationRoutine: @escaping @Sendable() -> Void) -> UInt64? {
        lock.withLock {
            self.taskCount += 1
            let taskID = self.taskCount
            self.taskExpirationRoutines[taskID] = expirationRoutine
            debugPrint("Background task \(taskID) registered, total: \(self.taskExpirationRoutines.count)")
            guard self.startOrStopBackgroundTask() else {
                self.taskExpirationRoutines.removeValue(forKey: taskID)
                return nil
            }
            
            return taskID
        }
    }
    
    public func removeTask(_ taskId: UInt64) {
        debugPrint("Removing task \(taskId)")
        lock.withLock {
            let removedRoutine = self.taskExpirationRoutines.removeValue(forKey: taskId)
            propeAssertDebug(removedRoutine != nil)
            PropeLog.warn("Task \(taskId) removed : \(removedRoutine != nil)")
            
            if self.taskExpirationRoutines.isEmpty {
                self.allTasksExpired = true //// so start another task if any
            }
            
            self.startOrStopBackgroundTask()
        }
    }
    
    @discardableResult
    private func startOrStopBackgroundTask() -> Bool {
        guard PropeAppContext().isMainApp else { return true }
        
        return lock.withLock {
            /// a background task runs when applicationDidEnterBackground and should stop when applicationDidBecomeActive
            /// if all tasks expired, app can run a bg task
            let shouldRunBackgroundTasks = (!self.isAppActive && (!self.taskExpirationRoutines.isEmpty || self.allTasksExpired))
            /// Does the maager got a background task to run?
            let hasBackgroundTask = self.currentbackgroundTaskId != .invalid
            
            if shouldRunBackgroundTasks == hasBackgroundTask { return true }
            else if shouldRunBackgroundTasks {
                PropeLog.info("Starting background task \(self.currentbackgroundTaskId)")
                return self.startBackgroundTask()
            } else {
                PropeLog.info("Expiring background task \(self.currentbackgroundTaskId)")
                self.currentbackgroundTaskId = .invalid
                return true
            }
        }
    }
    
    /// The notorious  expiration handler for [UIApplication beginBackgroundTaskWithExpirationHandler]'s handler
    private func backgroundTaskExpired() {
        let (bgTaskId, _taskExpirationRoutines) : (UIBackgroundTaskIdentifier, [UInt64 : @Sendable () -> Void]) = lock.withLock {
            let bgtaskId = self.currentbackgroundTaskId
            self.currentbackgroundTaskId = .invalid
            
            let _taskExpirationRoutines = self.taskExpirationRoutines
            self.taskExpirationRoutines.removeAll()
            return (bgtaskId, _taskExpirationRoutines)
        }
        
        //since assertIsOnMainThread ensures that all expiration routines are always called on main thread, there's no need to end the bg task until all completion routines are done.
        
        DispatchSyncMainThreadSafe {
            for expirationRoutine in _taskExpirationRoutines.values {
                expirationRoutine()
            }
            //once done expire all unexpired tasks
            if bgTaskId != .invalid {
                PropeAppContext().endBackgroundTask(bgTaskId)
            }
        }
    }
    
    private func startBackgroundTask() -> Bool {
        propeAssertDebug(PropeAppContext().isMainApp)
        
        guard PropeAppContext().isMainApp else { return true }
        
        return lock.withLock {
            propeAssertDebug(self.currentbackgroundTaskId == .invalid)
            self.currentbackgroundTaskId = PropeAppContext().beginBackgroundTask {
                AssertIsOnMainThread()
                self.backgroundTaskExpired()
            }
            
            guard self.currentbackgroundTaskId == .invalid else {
                PropeLog.warn("Background Task \(currentbackgroundTaskId) could not be started!")
                return false
            }
            return true
        }
    }
    
    
    //// Observe our app's state and decide to startOrStopBackgroundTask accordingly
    public func observeNotifications() {
        guard PropeAppContext().isMainApp else { return }
        let nc = NotificationCenter.default
        lock.withLock {
            self.clearObservers()
            
            self.didBecomeActiveObserver = nc.addObserver(forName: .PropeAppDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
                AssertIsOnMainThread()
                
                guard let self else { return }
                self.lock.withLock {
                    self.isAppActive = true
                    self.startOrStopBackgroundTask()
                }
            }
            
            self.willResignActiveObserver = nc.addObserver(forName: .PropeAppWillResignActive, object: nil, queue: nil) { [weak self] _ in
                AssertIsOnMainThread()
                
                guard let self else { return }
                self.lock.withLock {
                    self.isAppActive = false
                    self.startOrStopBackgroundTask()
                }
            }
        }
    }
    
    private func clearObservers() {
        if let didBecomeActiveObserver = self.didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(didBecomeActiveObserver, name: .PropeAppDidBecomeActive, object: nil)
            self.didBecomeActiveObserver = nil
        }
        if let willResignActiveObserver = self.willResignActiveObserver {
            NotificationCenter.default.removeObserver(willResignActiveObserver, name: .PropeAppWillResignActive, object: nil)
            self.willResignActiveObserver = nil
        }
        
    }
    
    /// with taskChainTimer, we chain the task which completed before another starts.
    /// a simple handover logic
    private func scheduleAllTasksExpiredState() {
        self.taskChainTimer?.invalidate()
        self.taskChainTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [weak self] timer in
            
            AssertIsOnMainThread()
        
            guard let self else {
                timer.invalidate()
                return
            }
            
            self.taskChainTimer?.invalidate()
            self.taskChainTimer = nil
            
            self.lock.withLock {
                self.allTasksExpired = false
                self.startOrStopBackgroundTask()
            }
            
        })
    }
}

