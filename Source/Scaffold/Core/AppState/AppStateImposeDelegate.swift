//
//  AppStateImpose.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import Combine

//// MARK: - impose AppState for
public protocol AppStateImposeDelegate : AppStateDelegate  {
    
    @MainActor
    func setAppIsReady()
    
    @MainActor
    func setAppIsReadyUIStillPending()
    
    @MainActor
    func setUIIsReady()
}

//For scene based apps
public typealias SceneStateImposer = AppStateImposer


public class AppStateImposer : ObservableObject, AppStateImposeDelegate {
    
    
    public init() { }
    
    private let readyFlag = ReadyFlag(name: "AppState")
    private let readyFlagUI = ReadyFlag(name: "UIState")
    
    public var isAppReady: Bool { readyFlag.isSet }
    public var isUIReady:  Bool { readyFlagUI.isSet }
    
    public func mockStateReady() {
        readyFlag.MockSetFlagReady(appReady: true)
    }
    // MARK: - AppStateImposeDelegates
    
    @MainActor
    public func setAppIsReady() {
        propeAssertDebug(!readyFlag.isSet)
        propeAssertDebug(!readyFlagUI.isSet)
        
        AppStateObjCBridge.readyFlag = readyFlag
        readyFlag.setIsReady()
        readyFlagUI.setIsReady()

    }
    
    @MainActor
    public func setAppIsReadyUIStillPending() {
        propeAssertDebug(!readyFlag.isSet)
        
        AppStateObjCBridge.readyFlag = readyFlag
        readyFlag.setIsReady()
        
    }
    
    @MainActor
    public func setUIIsReady() {
        readyFlagUI.setIsReady()
    }
    
    
    // MARK: - AppState

    // MARK: - AppState Blocks
    
    public func runNowOrWhenAppWillBecomeReady(
        _ block: @escaping @MainActor () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !CurrentAppContext().isRunningTests else {
            return
        }
        
        let label = Self.buildLabel(file: file, function: function, line: line)
        DispatchMainThreadSafe {
            self.readyFlag.runNowOrWhenAppWillBecomeReady(
                block,
                label: label
            )
        }
    }
    public func runNowOrWhenUIDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !CurrentAppContext().isRunningTests else {
            // We don't need to do any "on app ready" work in the tests.
            return
        }

        let label = Self.buildLabel(file: file, function: function, line: line)
        DispatchMainThreadSafe {
            self.readyFlagUI.runNowOrWhenDidBecomeReadySync(block, label: label)
        }
    }
    
    public func runNowOrWhenAppDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !PropeAppContext().isRunningTests else {
            // We don't need to do any "on app ready" work in the tests.
            return
        }
        
        let label = Self.buildLabel(file: file, function: function, line: line)
        DispatchMainThreadSafe {
            self.readyFlag.runNowOrWhenDidBecomeReadySync(block, label: label)
        }
    }
    // For delayed
    public func runNowOrWhenAppDidBecomeReadyAsync (
        _ block: @escaping @MainActor () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard !CurrentAppContext().isRunningTests else {
            // We don't need to do any "on app ready" work in the tests.
            return
        }

        let label = Self.buildLabel(file: file, function: function, line: line)
        DispatchMainThreadSafe {
            self.readyFlag.runNowOrWhenDidBecomeReadyAsync(block, label: label)
        }
    }
    
    public func runNowOrWhenMainAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        runNowOrWhenAppDidBecomeReadyAsync(
            {
                guard CurrentAppContext().isMainApp else { return }
                block()
            },
            file: file,
            function: function,
            line: line
        )
    }
    
    
    
    private static func buildLabel(file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        // We format the filename & line number in a format compatible
        // with XCode's "Open Quickly..." feature.
        return "[\(filename):\(line) \(function)]"
    }
}


@objc
public class AppStateObjcBridge: NSObject {
    
    fileprivate static var readyFlag: ReadyFlag?
    
    @objc
    public static var isAppReady: Bool { readyFlag?.isSet ?? false }
}

#if TESTABLE_BUILD


open class AppStateMock: AppStateDelegate {

    public init() {}

    public var isAppReady: Bool = false

    public var isUIReady: Bool = false

    open func runNowOrWhenAppWillBecomeReady(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    ) {
        // Do nothing
    }

    open func runNowOrWhenUIDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    ) {
        // Do nothing
    }

    open func runNowOrWhenAppDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    ) {
        // Do nothing
    }

    open func runNowOrWhenAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    ) {
        // Do nothing
    }

    open func runNowOrWhenMainAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    ) {
        // Do nothing
    }

}

#endif

