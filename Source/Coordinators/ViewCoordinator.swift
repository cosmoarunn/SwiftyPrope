//
//  ViewCoordinators.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//

import Foundation

import UIKit

/*public enum ViewEvent : BaseEvent {
    
    case processing
    case completed
    
}*/



protocol Coordinator {
    var navigationController : UINavigationController? { get set }
    
    func eventOccured(with type: ViewEvent) -> BaseEvent?
    func start()
}


open class ViewCoordinator: BaseCoordinator {
   
    public var navigationController: UINavigationController?
    
    public static var shared: any BaseCoordinator = ViewCoordinator()
    
    var childCoordinators: [BaseCoordinator] = []
    var childViewControllers: [PropeViewController] = []

    public init() {
        self.navigationController = UINavigationController()
       
    }
    open func eventOccurred(with type: PropeEvent) {
        //override in child view controllers
    }
    
    open func start() {
    
        for vc in childViewControllers {
            if vc.isViewLoaded {
                vc.coordinator = self
            }
            navigationController?.pushViewController(vc, animated: false)
        }
    }
}

