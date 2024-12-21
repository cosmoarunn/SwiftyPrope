//
//  DebugLogger.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import CocoaLumberjack
import AudioToolbox

private final class DebugLogFileManager: DDLogFileManagerDefault {
    private static func deleteLogFiles(inDirectory logsDirPath: String, olderThanDate cutoffDate: Date) {
        let logsDirectory = URL(fileURLWithPath: logsDirPath)
        let fileManager = FileManager.default
        guard let logFiles = try? fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [kCFURLContentModificationDateKey as URLResourceKey], options: .skipsHiddenFiles) else {
            return
        }
        for logFile in logFiles {
            guard logFile.pathExtension == "log" else {
                // This file is not a log file; don't touch it.
                continue
            }
            var lastModified: Date?
            do {
                var lastModifiedAnyObject: AnyObject?
                try (logFile as NSURL).getResourceValue(&lastModifiedAnyObject, forKey: .contentModificationDateKey)
                if let mtime = lastModifiedAnyObject as? NSDate {
                    lastModified = mtime as Date
                }
            } catch {
                // Couldn't get the modification date.
                continue
            }
            guard let lastModified else {
                // retrieving last modification date didn't throw but didn't return NSDate type
                continue
            }
            if lastModified.isAfter(cutoffDate) {
                // Still within the window.
                continue
            }
            // Attempt to remove the item, but don't stress if it fails.
            try? fileManager.removeItem(at: logFile)
        }
    }
    
    override func didArchiveLogFile(atPath logFilePath: String, wasRolled: Bool) {
        guard CurrentAppContext().isMainApp else {
            return
        }

        // Use this opportunity to delete old log files from extensions as well.
        // Compute an approximate "N days ago", ignoring calendars and dayling savings changes.
        let cutoffDate = Date(timeIntervalSinceNow: -kDayInterval * Double(maximumNumberOfLogFiles))

        for logsDirPath in DebugLogger.allLogsDirPaths {
            guard logsDirPath != logsDirectory else {
                // Managed directly by the base class.
                continue
            }
            Self.deleteLogFiles(inDirectory: logsDirPath, olderThanDate: cutoffDate)
        }
    }
}

public final class ErrorLogger: DDFileLogger {
    public static func playAlertSound() {
        AudioServicesPlayAlertSound(SystemSoundID(1023))
    }

    public override func log(message logMessage: DDLogMessage) {
        super.log(message: logMessage)
        // if Preferences.isAudibleErrorLoggingEnabled {  //defined in Preferences as UserDefaults Preferences
            Self.playAlertSound()
        //}
    }
}


public final class DebugLogger {
    public static var shared = DebugLogger()
    
    private init() { PropeSingleton.shared.register(self) }
    // MARK: Enable/Disable
    public var fileLogger: DDFileLogger?
    public var allLogFilePaths: Set<String> {
        let fileManager = FileManager.default
        var logPathSet = Set<String>()
        for logDirPath in DebugLogger.allLogsDirPaths {
            do {
                for filename in try fileManager.contentsOfDirectory(atPath: logDirPath) {
                    let logPath = logDirPath.appendingPathComponent(filename)
                    logPathSet.insert(logPath)
                }
            } catch {
                propeFailDebug("Failed to find log files: \(error)")
            }
        }
        // To be extra conservative, also add all logs from log file manager.
        // This should be redundant with the logic above.
        if let fileLogger {
            logPathSet.formUnion(fileLogger.logFileManager.unsortedLogFilePaths)
        }
        return logPathSet
    }
    public func enableFileLogging(appContext: AppContext, canLaunchInBackground: Bool) {
        let logsDirPath = appContext.debugLogsDirPath

        let logFileManager = DebugLogFileManager(
            logsDirectory: logsDirPath,
            defaultFileProtectionLevel: canLaunchInBackground ? .completeUntilFirstUserAuthentication : .completeUnlessOpen
        )

        // Keep last 3 days of logs - or last 3 logs (if logs rollover due to max
        // file size). Keep extra log files in internal builds.
        logFileManager.maximumNumberOfLogFiles = DebugFlags.extraDebugLogs ? 32 : 3

        let fileLogger = DDFileLogger(logFileManager: logFileManager)
        fileLogger.rollingFrequency = kDayInterval
        fileLogger.maximumFileSize = 3 * 1024 * 1024
        fileLogger.logFormatter =  LogFormatter() // ScrubbingLogFormatter()

        self.fileLogger = fileLogger
        DDLog.add(fileLogger)
    }

    public func disableFileLogging() {
        guard let fileLogger else { return }
        DDLog.remove(fileLogger)
        self.fileLogger = nil
    }
    public func enableTTYLoggingIfNeeded() {
        #if DEBUG
        guard let ttyLogger = DDTTYLogger.sharedInstance else { return }
        ttyLogger.logFormatter = LogFormatter()
        DDLog.add(ttyLogger)
        #endif
    }
    
    
}

extension DebugLogger {

    public static let mainAppDebugLogsDirPath = {
        //let dirPath = OWSFileSystem.cachesDirectoryPath().appendingPathComponent("Logs")
        let dirPath = URL(fileURLWithPath: PropeFileSystem.cachesDirectoryPath()).appendingPathComponent("Logs", conformingTo: .application).path
        PropeFileSystem.ensureDirectoryExists(dirPath)
        return dirPath
    }()
    public static let shareExtensionDebugLogsDirPath = {
        //let dirPath = OWSFileSystem.appSharedDataDirectoryPath().appendingPathComponent("ShareExtensionLogs")
        let dirPath = URL(fileURLWithPath: PropeFileSystem.appSharedDataDirectoryPath()).appendingPathComponent("ShareExtensionLogs", conformingTo: .application).path
        PropeFileSystem.ensureDirectoryExists(dirPath)
        return dirPath
    }()
    public static let nseDebugLogsDirPath = {
        //let dirPath = OWSFileSystem.appSharedDataDirectoryPath().appendingPathComponent("NSELogs")
        let dirPath = URL(fileURLWithPath: PropeFileSystem.appSharedDataDirectoryPath()).appendingPathComponent("NSELogs", conformingTo: .application).path
        PropeFileSystem.ensureDirectoryExists(dirPath)
        return dirPath
    }()
    
    public static let allLogsDirPaths: [String] = [
        DebugLogger.mainAppDebugLogsDirPath,
        DebugLogger.shareExtensionDebugLogsDirPath,
        DebugLogger.nseDebugLogsDirPath,
    ]
    
    /*func postLaunchLogCleanup(appContext: MainAppContext) {
        let shouldWipeLogs: Bool = {
            guard let lastLaunchVersion = AppVersionImpl.shared.lastCompletedLaunchMainAppVersion else {
                // This is probably a new version, but perhaps it's a really old version.
                return true
            }
            return AppVersionNumber(lastLaunchVersion) < AppVersionNumber("6.16.0.0")
        }()
        if shouldWipeLogs {
            wipeLogsAlways(appContext: appContext)
            Logger.warn("Wiped logs")
        }
    }*/

    func wipeLogsAlways(appContext: PropeAppContext) {
        //disableFileLogging()

        // Only the main app can wipe logs because only the main app can access its
        // own logs. (The main app can wipe logs for the other extensions.)
        for dirPath in Self.allLogsDirPaths {
            do {
                try FileManager.default.removeItem(atPath: dirPath)
            } catch {
                propeFailDebug("Failed to delete log directory: \(error)")
            }
        }

        //enableFileLogging(appContext: appContext, canLaunchInBackground: true)
    }
    
    
}
