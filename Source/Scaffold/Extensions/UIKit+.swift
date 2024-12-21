//
//  UIKit+.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import UIKit

public extension UIApplication {
    var frontmostViewControllerIgnoringAlerts: UIViewController? {
        guard let window = CurrentAppContext().mainWindow else {
            return nil
        }
        return window.findFrontmostViewController(ignoringAlerts: true)
    }

    @objc
    var frontmostViewController: UIViewController? {
        guard let window = CurrentAppContext().mainWindow else {
            return nil
        }
        return window.findFrontmostViewController(ignoringAlerts: false)
    }

    func openSystemSettings() {
        open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
}

public extension UIWindow {
    func findFrontmostViewController(ignoringAlerts: Bool) -> UIViewController? {
        guard let viewController = self.rootViewController else {
            propeFailDebug("Missing root view controller.")
            return nil 
        }
        return viewController.findFrontmostViewController(ignoringAlerts: ignoringAlerts)
    }
}
