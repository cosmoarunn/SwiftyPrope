//
//  ConversationSplitViewController.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import UIKit

class ConversationSplitViewController : UISplitViewController {
    
    private let appState: AppStateImposer
    
    let homeVC: HomeTabBarController
    private let detailPlaceholderVC = NoSelectedConversationViewController()
    
    private var lastActiveInterfaceOrientation = UIInterfaceOrientation.unknown
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent//Theme.isDarkThemeEnabled ? .lightContent : .default
    }
    
    @objc
    private func applyTheme() {
        view.backgroundColor = UIColor.green //Theme.isDarkThemeEnabled ? UIColor(rgbHex: 0x292929) : UIColor(rgbHex: 0xd6d6d6)
    }
    
    @objc
    private func orientationDidChange() {
        AssertIsOnMainThread()

        if let windowScene = view.window?.windowScene, windowScene.activationState == .foregroundActive {
            lastActiveInterfaceOrientation = windowScene.interfaceOrientation
        }
    }
    
    init(appState: AppStateImposer) {
        self.appState = appState
        self.homeVC = HomeTabBarController(appState: appState)
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = [homeVC, detailPlaceholderVC]
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .PropeAppDidBecomeActive, object: nil)
    }
    
    
    @objc 
    func didBecomeActive() {
        AssertIsOnMainThread()

        if let windowScene = view.window?.windowScene {
            lastActiveInterfaceOrientation = windowScene.interfaceOrientation
        }
    }
    
}


private class NoSelectedConversationViewController: UIViewController {
    let logoImageView = UIImageView()

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.blue

        logoImageView.image = #imageLiteral(resourceName: "signal-logo-128").withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = UIColor.quaternaryLabel
        logoImageView.contentMode = .scaleAspectFit
        //logoImageView.autoSetDimension(.height, toSize: 112)
        view.addSubview(logoImageView)

        
        //logoImageView.autoCenterInSuperview()
    }
}
