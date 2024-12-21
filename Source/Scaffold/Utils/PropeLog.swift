//
//  Logger.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import CocoaLumberjack
import SwiftUI

public enum PropeLogLevel : Int, CaseIterable {
    case ddAll = 0
    case ddInfo = 1
    case ddError = 2
    case ddDebug = 3
    case ddVerbose = 4
    case ddWarning = 5
    
    var level: DDLogLevel {
        switch self {
            
        case .ddAll:
                .all
        case .ddInfo:
                .info
        case .ddError:
                .error
        case .ddDebug:
                .debug
        case .ddVerbose:
                .verbose
        case .ddWarning:
                .warning
        }
    }
}

public enum PropeLog {
    static func log(
        _ logString: @autoclosure () -> String,
        flag: DDLogFlag,
        file: String,
        function: String,
        line: Int
    ) {
        //guard ShouldLogFlag(flag) else {  return }
        DDLog.log(asynchronous: true, message: DDLogMessage(
            message: logString(),
            level: PropeLogLevel.ddAll.level,
            flag: flag,
            context: 0,
            file: file,
            function: function,
            line: UInt(line),
            tag: nil,
            timestamp: nil
        ))
    }
    
    private static func log(
        _ logString: @autoclosure () -> String,
        flag: DDLogFlag,
        fileID: String,
        function: String,
        line: Int
    ) {
        log(logString(), flag: flag, file: (fileID as NSString).lastPathComponent, function: function, line: line)
    }

    public static func verbose(
        _ logString: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(logString(), flag: .verbose, fileID: file, function: function, line: line)
    }

    public static func debug(
        _ logString: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(logString(), flag: .debug, fileID: file, function: function, line: line)
    }

    public static func info(
        _ logString: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(logString(), flag: .info, fileID: file, function: function, line: line)
    }

    public static func warn(
        _ logString: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(logString(), flag: .warning, fileID: file, function: function, line: line)
    }

    public static func error(
        _ logString: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(logString(), flag: .error, fileID: file, function: function, line: line)
    }

    public static func flush() {
        DDLog.flushLog()
    }
}
