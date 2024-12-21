//
//  File.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import Combine

public class PropeSingleton : NSObject {
    public static let shared = PropeSingleton()
    private var registeredTypes = Set<ObjectIdentifier>()
    
    private override init() {
        super.init()
    }

    public func register(_ singleton: AnyObject) {
        assert({
            /*guard !CurrentAppContext().isRunningTests else {
                // Allow multiple registrations while tests are running.
                return true
            }*/
            let singletonTypeIdentifier = ObjectIdentifier(type(of: singleton))
            let (justAdded, _) = registeredTypes.insert(singletonTypeIdentifier)
            return justAdded
        }(), "Duplicate singleton.")
    }

    public static func register(_ singleton: AnyObject) {
        shared.register(singleton)
    }
}
