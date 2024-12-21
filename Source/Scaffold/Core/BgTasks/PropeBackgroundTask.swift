//
//  PropeBGTask.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 17/12/2024.
//

import Foundation
import BackgroundTasks


public class PropeBackgroundTask : NSObject {
    
    private let taskId: String
    
    private var internalTaskID: UInt64?

    private var completionHandler: (@MainActor @Sendable (PropeTaskState) -> Void)?
    
    private let lock = NSRecursiveLock()
    
    public convenience init(taskId: String) {
        self.init(taskId: taskId, completionHandler: nil)
    }
    
    
    public init(taskId: String, completionHandler: (@MainActor @Sendable (PropeTaskState) -> Void)?) {
        debugPrint("Initializing task : \(taskId)")
        //propeAssertDebug(taskId.isEmpty)
        
        self.taskId = taskId
        self.completionHandler = completionHandler
        
        super.init()
        
        startBackgroundTask()
    }
    
    public func getTaskIdentifier() -> String {
        return self.taskId
    }
    
     
    
    deinit {
        endBackgroundTask()
    }
    /// This func is private & called on init  such that it's executed only once on the main thread!
    private func startBackgroundTask() {
        internalTaskID = PropeBGTaskManager.shared().registerTask { [weak self]  in
            
            DispatchMainThreadSafe {
                guard let self else { return }
                
                // Make a local copy of completionBlock to ensure that it is called
                // exactly once.
                var completionHandler: (@MainActor @Sendable (PropeTaskState) -> Void)?
                
                self.lock.withLock {
                    guard self.internalTaskID != nil else { return }
                    
                    PropeLog.info("\(self.internalTaskID) background task has expired!")
                    self.internalTaskID = nil
                    
                    completionHandler = self.completionHandler
                    
                }
                if let completionHandler {
                    completionHandler(PropeTaskState.expired)
                }
            }
        }
        
        /// background start could not start!
        if internalTaskID == nil {
            var completionHandler: (@MainActor @Sendable (PropeTaskState) -> Void)?
            
            self.lock.withLock {
                completionHandler = self.completionHandler
                self.completionHandler = nil  //destroy it such that it can run only once
            }
            if let completionHandler {
                DispatchMainThreadSafe {
                    completionHandler(.notStarted)
                }
            }
        }
    }
    
    
    public func endBackgroundTask() {
        // Make a local copy of this state, since this method is called by `dealloc`.
        var completionHandler: (@MainActor @Sendable (PropeTaskState) -> Void)?

        lock.withLock {
            guard let taskId = self.internalTaskID else {
                return
            }
            PropeBGTaskManager.shared().removeTask(taskId)
            self.internalTaskID = nil

            completionHandler = self.completionHandler
            self.completionHandler = nil
        }

        // endBackgroundTask must be called on the main thread.
        DispatchMainThreadSafe {
            if let completionHandler {
                completionHandler(.expired)
            }
        }
    }
    
    
    
    
}
