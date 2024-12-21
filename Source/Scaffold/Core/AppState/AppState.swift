//
//  AppState.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation

/// MARK - Defines the app state is qualified to run
public protocol AppStateDelegate {
    
    var isAppReady: Bool { get }
    var isUIReady: Bool { get }
    
    //For necessary routines like db writing etc, must be executed soon after launch
    func runNowOrWhenAppWillBecomeReady(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    )

    func runNowOrWhenUIDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    )

    func runNowOrWhenAppDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    )
    
    // For delayed
    func runNowOrWhenAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    )

    func runNowOrWhenMainAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        file: String,
        function: String,
        line: Int
    )
    
    
}


///// Implementation

extension AppStateDelegate {
    
    public func runNowOrWhenAppWillBecomeReady(
        _ block: @escaping @MainActor () -> Void,
        _file: String = #file,
        _function: String = #function,
        _line: Int = #line
    ) {
        self.runNowOrWhenAppWillBecomeReady(
            block,
            file: _file,
            function: _function,
            line: _line
        )
    } 
    
    func runNowOrWhenUIDidBecomeReadySync(
        _ block: @escaping @MainActor () -> Void,
        _file: String,
        _function: String,
        _line: Int
    ) {
        self.runNowOrWhenUIDidBecomeReadySync (
            block,
            file: _file,
            function: _function,
            line: _line
        )
    }
    
    func runNowOrWhenAppDidBecomeReadySync (
        _ block: @escaping @MainActor () -> Void,
        _file: String,
        _function: String,
        _line: Int
    ) {
        self.runNowOrWhenAppDidBecomeReadySync (
            block,
            file: _file,
            function: _function,
            line: _line
        )
    }
    // For delayed
    func runNowOrWhenAppDidBecomeReadyAsync (
        _ block: @escaping @MainActor () -> Void,
        _file: String,
        _function: String,
        _line: Int
    ) {
        self.runNowOrWhenAppDidBecomeReadyAsync(
            block,
            file: _file,
            function: _function,
            line: _line
        )
    }
    
    public func runNowOrWhenMainAppDidBecomeReadyAsync(
        _ block: @escaping @MainActor () -> Void,
        _file: String = #file,
        _function: String = #function,
        _line: Int = #line
    ) {
        self.runNowOrWhenMainAppDidBecomeReadyAsync(
            block,
            file: _file,
            function: _function,
            line: _line
        )
    }
    
    
    
}


@objc
public class AppStateObjCBridge : NSObject {
    
     static var readyFlag: ReadyFlag?
    
    /// Global static state exposing ``AppReadiness/isAppReady``.
    /// If possible, take ``AppReadiness`` as a dependency and access it as an instance instead.
    /// This type exists to bridge to objc code and legacy code requiring globals access.
    @objc
    public static var isAppReady: Bool { readyFlag?.isSet ?? false }
}

/*
 
 #if TESTABLE_BUILD

 open class AppReadinessMock: AppReadiness {

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

 
 */
