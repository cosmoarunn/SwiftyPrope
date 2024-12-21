//
//  PropeManager.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 19/12/2024.
//

import Foundation


public protocol PropeManagerDelegate {
    
    init()
    
    
    func didBecomeActive()
    func willResignActive()
    func didEnterBackground()
    func willEnterForeground()

    
}

public class PropeManager : PropeManagerDelegate {
    
    public static let shared = {
        if Thread.isMainThread {  return PropeManager() } else {
            return DispatchQueue.main.sync {
                PropeManager()
            }
        }
    }()

    
    public required init() {
        
        PropeSingleton.shared.register(self)
        
        let nc = NotificationCenter.default
        
        nc.addObserver(
            self, selector: #selector(didBecomeActive), name: .PropeAppDidBecomeActive, object: nil)
        nc.addObserver(
            self, selector: #selector(willResignActive), name: .PropeAppWillResignActive, object: nil)
        nc.addObserver(
            self, selector: #selector(didEnterBackground), name: .PropeAppDidEnterBackground, object: nil)
        nc.addObserver(
            self, selector: #selector(willEnterForeground), name: .PropeAppWillEnterForeground, object: nil)
    }
    
    @objc public func didBecomeActive() {
        ///// override & execute Manager's routines when app did become active
    }
    
    @objc public func willResignActive() {
        ///// override & execute Manager's routines when app will resign active
    }
    
    @objc public func didEnterBackground() {
        ///// override & execute Manager's routines when app did enter background
    }
    
    @objc public func willEnterForeground() {
        ///// override & execute Manager's routines when app will enter foreground
    }
    
    
}
