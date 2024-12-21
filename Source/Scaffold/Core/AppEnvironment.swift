//
//  AppEnvironment.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import Combine

public class AppEnvironment : NSObject, ObservableObject {
    
    private static var _shared: AppEnvironment?
    
    private var appLaunchTime: CFTimeInterval?
    
    static func setSharedEnvironment(_ appEnvironment: AppEnvironment) {
        propePrecondition(self._shared == nil)
        self._shared = appEnvironment
    }
    
    public func timeAppLaunched(at launchTime: CFTimeInterval) {
        self.appLaunchTime = launchTime
    }
    
    @objc
    public class var shared: AppEnvironment { _shared! }

    /// Objects tied to this AppEnvironment that simply need to be retained.
    @MainActor
    var ownedObjects = [AnyObject]()
    
    let windowManagerRef = WindowManager()
    
    override init() {
        super.init()
        PropeSingleton.shared.register(self)
    }
    
    
    func setup(for appState: AppStateDelegate) {
        
        // Initiate call service, badgemanager etc
        appState.runNowOrWhenAppWillBecomeReady {
            print("runNowOrWhenAppWillBecomeReady Blocks go here")
        }
        
        appState.runNowOrWhenMainAppDidBecomeReadyAsync {
            print("runNowOrWhenMainAppDidBecomeReadyAsync Blocks go here")
        }
        
    }
    
    
}
