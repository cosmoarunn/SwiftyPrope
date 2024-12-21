//
//  AppVersion.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import SwiftUI

class AppVersionManager: ObservableObject {
    static let shared = AppVersionManager()
    
    @Published var version: String = ""
    private init() {
        // Get the current version from the Info.plist using a safer method
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.version = version
        } else {
            print("Could not retrieve version string from Info.plist.  Using placeholder.")
            self.version = "1.0.0"
        }
    }
    
    public var iosVersionString: String {
        let majorMinor = UIDevice.current.systemVersion
        let buildNumber = String(sysctlKey: "kern.osversion") ?? "nil"
        return "\(majorMinor) (\(buildNumber))"
    }
}
