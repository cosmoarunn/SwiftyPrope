//
//  AppContextDelegate.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import CoreGraphics
import UIKit

public protocol AppContext {
    var type: AppContextType { get }
    var isMainApp: Bool { get }
    var isMainAppAndActive: Bool { get }
    
    @MainActor
    //var C: Bool { get } //// TODO: What is this?
    var isNSE: Bool { get }
    /// Whether the user is using a right-to-left language like Arabic.
    var isRTL: Bool { get }
    var isRunningTests: Bool { get }
    var mainWindow: UIWindow? { get set }
    var frame: CGRect { get }
    
    var reportedApplicationState: UIApplication.State { get }
    func isInBackground() -> Bool
    
    func isAppForegroundAndActive() -> Bool
    
    /// Should start a background task if isMainApp is YES.
    /// Should just return UIBackgroundTaskInvalid if isMainApp is NO.
    func beginBackgroundTask(with expirationHandler: @escaping BackgroundTaskExpirationHandler) -> UIBackgroundTaskIdentifier
    
    /// Should be a NOOP if isMainApp is NO.
    func endBackgroundTask(_ backgroundTaskIdentifier: UIBackgroundTaskIdentifier)
    func ensureSleepBlocking(_ shouldBeBlocking: Bool, blockingObjectsDescription: String)
    
    /// Returns the VC that should be used to present alerts, modals, etc.
    func frontmostViewController() -> UIViewController?
    func openSystemSettings()
    func open(_ url: URL, completion: ((_ success: Bool) -> Void)?)
    func runNowOrWhenMainAppIsActive(_ block: @escaping AppActiveBlock)
    
    var appLaunchTime: Date { get }
    /// Will be updated every time the app is foregrounded.
    var appForegroundTime: Date { get }
    
    /// App Directory Paths
    func appDocumentDirectoryPath() -> String
    func appSharedDataDirectoryPath() -> String
    func appDatabaseBaseDirectoryPath() -> String
    
    func appUserDefaults() -> UserDefaults
    /// This method should only be called by the main app.
    func mainApplicationStateOnLaunch() -> UIApplication.State
    func canPresentNotifications() -> Bool
    var shouldProcessIncomingMessages: Bool { get }
    var hasUI: Bool { get }
    var debugLogsDirPath: String { get }

    /// WARNING: Resets all persisted app data. (main app only).
    ///
    /// App becomes unusable. As of time of writing, the only option
    /// after doing this is to terminate the app and relaunch.
    func resetAppDataAndExit() -> Never
    
    
    
}


@objcMembers
public final class AppContextObjCBridge : NSObject {
    
    public static let shared = AppContextObjCBridge()
    
    //Notification names
    public static let PropeApplicationWillResignActiveNotification = Notification.Name.PropeAppWillResignActive
    public static let PropeApplicationWillEnterForeground = Notification.Name.PropeAppWillEnterForeground
    public static let PropeApplicationDidEnterBackground = Notification.Name.PropeAppDidEnterBackground
    public static let PropeApplicationDidBecomeActiveNotification = Notification.Name.PropeAppDidBecomeActive
    public static let PropeApplicationWillTerminateNotification = Notification.Name.PropeAppWillTerminate
    
    private var appContext: any AppContext  { // { }  //global currentAppContext()
        currentAppContext!
    }
    
   
    
    public override init() {
        //super.init()
        //PropeSingleton.register(self)
    }
    
    
    
    public var addDocumentDirectoryPath: String {
        appContext.appDocumentDirectoryPath()
    }
    
    public var appSharedDataDirectoryPath: String {
        appContext.appSharedDataDirectoryPath()
    }

    public var appLaunchTime: Date {
        appContext.appLaunchTime
    }

    public var isMainApp: Bool {
        appContext.isMainApp
    }

    public var isMainAppAndActive: Bool {
        appContext.isMainAppAndActive
    }

    public var isRunningTests: Bool {
        appContext.isRunningTests
    }
    
    public func beginBackgroundTask(expirationHandler: @escaping () -> Void) -> UIBackgroundTaskIdentifier {
        appContext.beginBackgroundTask(with: expirationHandler)
    }
    public func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        appContext.endBackgroundTask(identifier)
    }
}

private var appState: AppStateImposer?

public func currentAppState() -> AppStateImposer {
    appState!
}

private var currentAppContext: (any AppContext)?

public func CurrentAppContext() -> any AppContext {
    // Yuck, but the objc function that came before this function lied about
    // not being able to return nil so the entire app is already written
    // assuming this can't be nil though it always could have been.
    //if currentAppContext == nil   { currentAppContext = PropeAppContext()   }
    return currentAppContext!
}

public func SetCurrentAppContext(_ appContext: any AppContext) {
    currentAppContext = appContext
}

extension AppContext {
    public var isMainApp: Bool {
        type == .main
    }

    public var isNSE: Bool {
        type == .nse  //Notification Service Extension
    }
}

/*
 The Notification Service Extension (NSE) in OneSignal's mobile apps allows users to receive data in the background or override notification settings:
 Receive data in the background: Users can receive data in the background with or without a notification.
 Override notification settings: Users can override specific notification settings, such as the vibration pattern, accent color, or other NotificationCompat options.
 The NSE is available for both Android and iOS
 */
