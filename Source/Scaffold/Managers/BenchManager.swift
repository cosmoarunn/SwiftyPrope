//
//  BenchManager.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import SwiftUI

private func BenchAsync(title: String, logInProduction: Bool = false, block: (@escaping () -> Void) -> Void) {
    let startTime = CACurrentMediaTime()
    block {
        if !DebugFlags.reduceLogChatter {
            let timeElapsed = CACurrentMediaTime() - startTime
            let formattedTime = String(format: "%0.2fms", timeElapsed * 1000)
            let logMessage = "[Bench] title: \(title), duration: \(formattedTime)"
            if logInProduction {
                PropeLog.info(logMessage)
            } else {
                PropeLog.debug(logMessage)
            }
        }
    }
}

/*public func Bench(title: String,
                  memorySamplerRatio: Float,
                  logInProduction: Bool = false,
                  block: (MemorySampler) throws -> Void) rethrows {
    let memoryBencher = MemoryBencher(title: title, sampleRatio: memorySamplerRatio)
    try Bench(title: title, logInProduction: logInProduction) {
        try block(memoryBencher)
        memoryBencher.complete()
    }
}*/

public func BenchEventStart(title: String, eventId: BenchmarkEventId, logInProduction: Bool = false) {
    BenchAsync(title: title, logInProduction: logInProduction) { finish in
        eventQueue.sync {
            runningEvents[eventId] = Event(title: title, eventId: eventId, completion: finish)
        }
    }
}

public func BenchEventComplete(eventId: BenchmarkEventId) {
    BenchEventComplete(eventIds: [eventId])
}

public func BenchEventComplete(eventIds: [BenchmarkEventId]) {
    eventQueue.sync {
        for eventId in eventIds {
            guard let event = runningEvents.removeValue(forKey: eventId) else {
                propeFailDebug("Can't end event that wasn't started.")
                return
            }
            event.completion()
        }
    }
}

public typealias BenchmarkEventId = String

private struct Event {
    let title: String
    let eventId: BenchmarkEventId
    let completion: () -> Void
}

private var runningEvents: [BenchmarkEventId: Event] = [:]
private let eventQueue = DispatchQueue(label: "org.signal.bench")


@objc
public class BenchManager: NSObject {
    @objc
    public class func bench(title: String, logIfLongerThan intervalLimit: TimeInterval, logInProduction: Bool, block: () -> Void) {
        Bench(title: title, logIfLongerThan: intervalLimit, logInProduction: logInProduction, block: block)
    }
}


public func Bench<T>(title: String, logIfLongerThan intervalLimit: TimeInterval = 0, logInProduction: Bool = false, block: () throws -> T) rethrows -> T {
    let startTime = CACurrentMediaTime()
    let value = try block()
    let timeElapsed = CACurrentMediaTime() - startTime

    if timeElapsed > intervalLimit {
        /*if !DebugFlags.reduceLogChatter {
            let formattedTime = String(format: "%0.2fms", timeElapsed * 1000)
            let logMessage = "[Bench] title: \(title), duration: \(formattedTime)"
            if logInProduction {
                Logger.info(logMessage)
            } else {
                Logger.debug(logMessage)
            }
        }*/
        let formattedTime = String(format: "%0.2fms", timeElapsed * 1000)
        let logMessage = "[Bench] title: \(title), duration: \(formattedTime)"
        if logInProduction {
            PropeLog.info(logMessage)
            
        } else {
            PropeLog.debug(logMessage)
        }
        
        debugPrint(logMessage)
    }
    return value
}
