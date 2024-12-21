//
//  TabsCoordinator.swift
//  PropeEpafes
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//

import Foundation
import UIKit

public enum TabEvent {
    case calls
    case conversations
    case contacts
    case viewStory
}
 
public protocol Tabbable {
    var tabCoordinator: ViewCoordinator? { get set }
}

public protocol BaseTabCoordinator {
    var tabController : UITabBarController? { get set }
    var appState: AppStateImposer? { get set }
    
    func tabSelect(with type: TabEvent)
    func setup()
}

