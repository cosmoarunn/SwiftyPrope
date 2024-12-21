//
//  PropeWindow.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import UIKit

public class PropeWindow: UIWindow {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        /*NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
        
        applyTheme()*/
        
       
    }

    // This useless override is defined so that you can call `-init` from Swift.
    public override init(windowScene: UIWindowScene) {
        fatalError("init(windowScene:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc
    private func themeDidChange() {
        applyTheme()
    }
    
  
    
    private func applyTheme() {
        // Ensure system UI elements use the appropriate styling for the selected theme.
        /*switch Theme.getOrFetchCurrentMode() {
        case .light:
            overrideUserInterfaceStyle = .light
        case .dark:
            overrideUserInterfaceStyle = .dark
        case .system:
            overrideUserInterfaceStyle = .unspecified
        }*/
        overrideUserInterfaceStyle = .dark
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        /*if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            Theme.systemThemeChanged()
        }*/
    }
}
