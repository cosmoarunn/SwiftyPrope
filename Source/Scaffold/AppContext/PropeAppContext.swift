//
//  PropeAppContext.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import SwiftUI
import UIKit

public class PropeAppContext : NSObject, AppContext {
    
    public let type: AppContextType = .main
    public let appLaunchTime: Date
    
    public var appForegroundTime: Date
    
    
    public override init() {
        
        _reportedApplicationState = AtomicValue(.inactive, lock: .init())
        let launchDate = Date()
        appLaunchTime = launchDate
        appForegroundTime = launchDate
        _mainApplicationStateOnLaunch = UIApplication.shared.applicationState
        
        super.init()
        
        let nc = NotificationCenter.default
        
        nc.addObserver(
            self, 
            selector: #selector(applicationWillEnterForeground),
            name: .PropeAppWillEnterForeground, object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: .PropeAppWillEnterForeground, object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: .PropeAppWillEnterForeground, object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: .PropeAppWillEnterForeground, object: nil
        )
    }
    
    private let _mainApplicationStateOnLaunch: UIApplication.State
    public func mainApplicationStateOnLaunch() -> UIApplication.State { _mainApplicationStateOnLaunch }
    
    private let _reportedApplicationState: AtomicValue<UIApplication.State>
    
    public var reportedApplicationState: UIApplication.State {
        get { _reportedApplicationState.get() }
        set {
            AssertIsOnMainThread()
            _reportedApplicationState.set(newValue)
        }
    }
    
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        AssertIsOnMainThread()
        
        self.reportedApplicationState = .inactive
        self.appForegroundTime = Date()
        
        BenchManager.bench(title: "Slow WillEnterForeground", logIfLongerThan: 0.2, logInProduction: true) {
            NotificationCenter.default.post(name: .PropeAppWillEnterForeground, object: nil)
        }
        
    }
    
    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        AssertIsOnMainThread()
        
        self.reportedApplicationState = .background
        
        BenchManager.bench(title: "Slow DidEnterBackground", logIfLongerThan: 0.1, logInProduction: true) {
            NotificationCenter.default.post(name: .PropeAppDidEnterBackground, object: nil)
        }
    }
    
    @objc
    private func applicationWillResignActive(_ notification: Notification) {
        AssertIsOnMainThread()
        
        BenchManager.bench(title: "Slow WillResignActive", logIfLongerThan: 0.2, logInProduction: true) {
            NotificationCenter.default.post(name: .PropeAppWillResignActive, object: nil)
        }
    }
    
    @objc
    private func applicationDidBecomeActive(_ notification: Notification) {
        AssertIsOnMainThread()
        
        BenchManager.bench(title: "Slow DidBecomeActive", logIfLongerThan: 0.2, logInProduction: true) {
            NotificationCenter.default.post(name: .PropeAppDidBecomeActive, object: nil)
        }
        
        //Run active state blocks
        self.runAppActiveBlocks()
    }
    
    
    public var isMainAppAndActive: Bool { UIApplication.shared.applicationState == .active }
    
    var C: Bool = false
    
    public var isRTL: Bool { UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft }
    
    public var isRunningTests: Bool {
        #if TESTABLE_BUILD
        return getenv("runningTests_dontStartApp")
        #else
        return false
        #endif
    }
    
    public var mainWindow: UIWindow?
    
    public var frame: CGRect { self.mainWindow?.frame ?? .zero }
    
    
    
    private var appActiveBlocks = [AppActiveBlock]()
    
    
    public func isInBackground() -> Bool {  reportedApplicationState == .background }
    
    public func isAppForegroundAndActive() -> Bool { reportedApplicationState == .active }
    
    public func beginBackgroundTask(with expirationHandler: @escaping BackgroundTaskExpirationHandler) -> UIBackgroundTaskIdentifier {
        UIApplication.shared.beginBackgroundTask(expirationHandler: expirationHandler)
    }
    
    /// Handled by default in threadsafe BGTaskManager.removeTask function with locks in place
    /// the following will end task abruptly leading to premature app state or data corruption.
    /// use it with caution
    public func endBackgroundTask(_ backgroundTaskIdentifier: UIBackgroundTaskIdentifier)  {
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
    }
    
    public func ensureSleepBlocking(_ shouldBeBlocking: Bool, blockingObjectsDescription: String) {
        if UIApplication.shared.isIdleTimerDisabled != shouldBeBlocking {
            if shouldBeBlocking {
                PropeLog.info("Blocking sleep because of: \(blockingObjectsDescription)")
            } else {
                PropeLog.info("Unblocking sleep.")
            }
        }
    }
    
    public func frontmostViewController() -> UIViewController? {
        UIApplication.shared.frontmostViewControllerIgnoringAlerts
    }
    
    public func openSystemSettings() {  UIApplication.shared.openSystemSettings() }
    
    public func open(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, completionHandler:  completion)
    }
    
    public func runNowOrWhenMainAppIsActive(_ block: @escaping AppActiveBlock) {
        DispatchMainThreadSafe {
            if self.isMainAppAndActive {
                block()
                return
            }
        }
        self.appActiveBlocks.append(block)
    }
    
    private func runAppActiveBlocks() {
        AssertIsOnMainThread()
        let appActiveBlocks = self.appActiveBlocks
        self.appActiveBlocks = []
        for block in appActiveBlocks { block() }
    }
    
    
    public func appDocumentDirectoryPath() -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.path
    }
    
    public func appSharedDataDirectoryPath() -> String {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PropeConstants.applicationGroup)!.path
    }
     
    public func appDatabaseBaseDirectoryPath() -> String {
        appSharedDataDirectoryPath()
    }
    
    public func appUserDefaults() -> UserDefaults {
        UserDefaults(suiteName: PropeConstants.applicationGroup)!
    }
    
    public func canPresentNotifications() -> Bool { true }
    
    
    
    public var shouldProcessIncomingMessages: Bool = true
    
    public var hasUI: Bool = true
    
    public var debugLogsDirPath: String { DebugLogger.mainAppDebugLogsDirPath }
     
    public func resetAppDataAndExit() -> Never {
        debugPrint("Not implemented yet!")
        //UIApplication.shared.resetAppDataAndExit()
        exit(0)
    }
    
    
}
