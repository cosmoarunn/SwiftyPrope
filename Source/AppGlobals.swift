//
//  AppGlobals.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 17/12/2024.
//

import Foundation


#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif


public typealias Completion = () -> Void
public typealias AsyncCompletion = (() async -> Void)?
public typealias MainActorCompletion =  @MainActor () -> Void
public typealias MainActorAsyncCompletion = (@MainActor () async -> Void)?

public typealias ErrorCompletion = (Error) -> Void
public typealias AsyncErrorCompletion = (Error) async -> Void
public typealias MainActorErrorCompletion = @MainActor () -> Void
public typealias MainActorAsyncErrorCompletion = (@MainActor () async -> Void)?

public typealias ResultCompletion<T> = (Result<T, Error>) -> Void
public typealias AsyncResultCompletion<T> = (Result<T, Error>) async -> Void

/// MARK :   Scenes & Windows

public var AppConnectedScenes: Set<UIScene> {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    //return UIApplication.shared.connectedScenes.filter(\.self is UIWindowScene)
    return UIApplication.shared.connectedScenes
#else
    return []
#endif
}

public var AppCurrentScene: UIScene? {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
#else
    return nil
#endif
}

public var AppWindows: [UIWindow] {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    return  AppCurrentScene
                .flatMap({ $0 as? UIWindowScene })?.windows ?? []
                
#else
    return []
#endif
}

public var AppKeyWindow: UIWindow? {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    return AppWindows.first(where: \.isKeyWindow)
#else
    return nil
#endif
}

var keyWindowPresentedController: UIViewController? {
    var viewController = AppKeyWindow?.rootViewController
        
        // If root `UIViewController` is a `UITabBarController`
        if let presentedController = viewController as? UITabBarController {
            // Move to selected `UIViewController`
            viewController = presentedController.selectedViewController
        }
        
        // Go deeper to find the last presented `UIViewController`
        while let presentedController = viewController?.presentedViewController {
            // If root `UIViewController` is a `UITabBarController`
            if let presentedController = presentedController as? UITabBarController {
                // Move to selected `UIViewController`
                viewController = presentedController.selectedViewController
            } else {
                // Otherwise, go deeper
                viewController = presentedController
            }
        }
        
        return viewController
    }



