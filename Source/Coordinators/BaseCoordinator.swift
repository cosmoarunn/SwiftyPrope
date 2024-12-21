//
//  CoOrdinator.swift
//  PropeEpafes
//
//  Created by ARUN PANNEERSELVAM on 15/12/2024.
//

import Foundation
import UIKit

public enum BaseEvent : Int, CaseIterable {
    case processing
    case completed
    
    var description: String {
        switch self {
        case .processing: return "processing"
        case .completed: return "completed"
        }
    }
}

public enum ViewEvent {
    case viewStory
    case captcha
}

public enum PropeEvent {
    case baseEvent(value: BaseEvent), viewEvent(value: ViewEvent)
}


public protocol Coordinatable {
    var coordinator: ViewCoordinator? { get set }
}

public protocol BaseCoordinator {
    var navigationController : UINavigationController? { get set }
    
    static var shared: BaseCoordinator { get }
    
    func eventOccurred(with type: PropeEvent)
    func start()
}



