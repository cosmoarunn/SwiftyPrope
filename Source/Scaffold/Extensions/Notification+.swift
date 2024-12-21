//
//  Notification+.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation

public extension Notification.Name {
    
    static let PropeAppDidEnterBackground = Notification.Name("PropeApplicationDidEnterBackgroundNotification")
    static let PropeAppWillEnterForeground = Notification.Name("PropeApplicationWillEnterForegroundNotification")
    static let PropeAppWillResignActive = Notification.Name("PropeApplicationWillResignActiveNotification")
    static let PropeAppDidBecomeActive = Notification.Name("PropeApplicationDidBecomeActiveNotification")
    static let PropeAppWillTerminate = Notification.Name("PropeApplicationWillTerminateNotification")
    
}
