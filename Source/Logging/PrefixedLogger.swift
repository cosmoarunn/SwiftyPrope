//
//  PrefixedLogger.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
open class PrefixedLogger {
    private let prefix: String
    private var suffix: String

    public static func empty() -> PrefixedLogger {
        return PrefixedLogger(rawPrefix: "")
    }

    public init(prefix: String, suffix: String? = nil) {
        self.prefix = "\(prefix) "
        self.suffix = suffix.map { " \($0)" } ?? ""
    }

    private init(rawPrefix: String, rawSuffix: String? = nil) {
        self.prefix = rawPrefix
        self.suffix = rawSuffix ?? ""
    }

    public func suffixed(with extraSuffix: String) -> PrefixedLogger {
        return PrefixedLogger(
            prefix: prefix,
            suffix: suffix + " \(extraSuffix)"
        )
    }

    open func verbose(
        _ logString: @autoclosure () -> String,
        flushImmediately: Bool = false,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        PropeLog.verbose(
            buildLogString(logString()),
            file: file,
            function: function,
            line: line
        )

        if flushImmediately { flush() }
    }

    open func debug(
        _ logString: @autoclosure () -> String,
        flushImmediately: Bool = false,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        PropeLog.debug(
            buildLogString(logString()),
            file: file,
            function: function,
            line: line
        )

        if flushImmediately { flush() }
    }

    open func info(
        _ logString: @autoclosure () -> String,
        flushImmediately: Bool = false,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        PropeLog.info(
            buildLogString(logString()),
            file: file,
            function: function,
            line: line
        )

        if flushImmediately { flush() }
    }

    open func warn(
        _ logString: @autoclosure () -> String,
        flushImmediately: Bool = false,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        PropeLog.warn(
            buildLogString(logString()),
            file: file,
            function: function,
            line: line
        )

        if flushImmediately { flush() }
    }

    open func error(
        _ logString: @autoclosure () -> String,
        flushImmediately: Bool = false,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        PropeLog.error(
            buildLogString(logString()),
            file: file,
            function: function,
            line: line
        )

        if flushImmediately { flush() }
    }

    open func flush() {
        PropeLog.flush()
    }

    private func buildLogString(_ logString: String) -> String {
        "\(prefix)\(logString)\(suffix)"
    }
}
