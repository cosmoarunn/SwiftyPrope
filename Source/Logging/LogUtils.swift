//
//  LogUtils.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
/**
 * We synchronize access to state in this class using this queue.
 */
public func assertOnQueue(_ queue: DispatchQueue) {
    dispatchPrecondition(condition: .onQueue(queue))
}

@inlinable
public func AssertIsOnMainThread(
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !Thread.isMainThread {
        propeFailDebug("Must be on main thread.", logger: logger, file: file, function: function, line: line)
    }
}

@inlinable
public func AssertNotOnMainThread(
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if Thread.isMainThread {
        propeFailDebug("Must be off main thread.", logger: logger, file: file, function: function, line: line)
    }
}

@inlinable
public func propeFailDebug(
    _ logMessage: String,
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    logger.error(logMessage, file: file, function: function, line: line)
    /*if IsDebuggerAttached() {
        TrapDebugger()
    } else {
        assertionFailure(logMessage)
    }*/
    assertionFailure(logMessage)
}

@inlinable
public func propeFail(
    _ logMessage: String,
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) -> Never {
    logger.error(Thread.callStackSymbols.joined(separator: "\n"))
    propeFailDebug(logMessage, logger: logger, file: file, function: function, line: line)
    logger.flush()
    fatalError(logMessage)
}

@inlinable
public func propeAssertDebug(
    _ condition: Bool,
    _ message: @autoclosure () -> String = String(),
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !condition {
        let message: String = message()
        propeFailDebug(message.isEmpty ? "Assertion failed." : message, logger: logger, file: file, function: function, line: line)
    }
}

/// Like `Swift.precondition(_:)`, this will trap if `condition` evaluates to
/// `false`. Also performs additional logging before terminating the process.
/// See `propeFail(_:)` for more information about logging.
@inlinable
public func propePrecondition(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    logger: PrefixedLogger = .empty(),
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !condition() {
        let message: String = message()
        propeFail(message.isEmpty ? "Assertion failed." : message, logger: logger, file: file, function: function, line: line)
    }
}

// MARK: -

@objc
public class PropeUtils: NSObject {
    // This method can be invoked from Obj-C to exit the app.
    @objc
    public class func propeFailObjC(
        _ logMessage: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) -> Never {
        propeFail(logMessage, file: file, function: function, line: line)
    }
}
