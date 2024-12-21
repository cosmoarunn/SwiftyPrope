//
//  BadgeManager.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation

public protocol BadgeObserver {
    func didUpdateBadgeCount(
        _ badgeManager: BadgeManager,
        badgeCount: BadgeCount
    )
}

public struct BadgeCount {
    public let unreadChatCount: UInt
    public let unreadCallsCount: UInt

    public var unreadTotalCount: UInt {
        unreadChatCount + unreadCallsCount
    }
}

public class BadgeManager {
    public typealias FetchBadgeCountBlock = () -> BadgeCount
    
    
    
}
