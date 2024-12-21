//
//  UIApplication+.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import UIKit
import CryptoKit

public extension UIApplication {
    
    static func uncaughtExceptionHandler(_ exception: NSException, isInternalLogging:Bool ) {
        //var isInternalLogging = false //implement this on DebugFlags enum
        if isInternalLogging {
            PropeLog.error("exception: \(exception)")
            PropeLog.error("name: \(exception.name)")
            PropeLog.error("reason: \(String(describing: exception.reason))")
            PropeLog.error("userInfo: \(String(describing: exception.userInfo))")
        } else {
            let reason = exception.reason ?? ""
            let reasonData = reason.data(using: .utf8) ?? Data()
            let reasonHash = Data(SHA256.hash(data: reasonData)).base64EncodedString()

            var truncatedReason = reason.prefix(20)
            if let spaceIndex = truncatedReason.lastIndex(of: " ") {
                truncatedReason = truncatedReason[..<spaceIndex]
            }
            let maybeEllipsis = (truncatedReason.endIndex < reason.endIndex) ? "..." : ""
            PropeLog.error("\(exception.name): \(truncatedReason)\(maybeEllipsis) (hash: \(reasonHash))")
        }
        PropeLog.error("callStackSymbols: \(exception.callStackSymbols.joined(separator: "\n"))")
        PropeLog.flush()
    }

    
}
