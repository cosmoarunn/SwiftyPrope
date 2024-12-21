//
//  AppStateEndorser.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation

//// MARK: - Ratifies, qulifies & endorses app on behalf of AppState


public class ReadyFlag  {
    private let unfairLock = UnfairLock()
    
    private struct ReadyTask {
        let label: String?
        let block: ReadyBlock

        var displayLabel: String {
            label ?? "unknown"
        }
    }
    
    private let name: String

    private static let blockLogDuration: TimeInterval = 0.01
    private static let groupLogDuration: TimeInterval = 0.1
    
    @objc
    public init(name: String) {
        self.name = name
    }
    
    // This property should only be set with unfairLock.
    // It can be read from any queue.
    private let flag = AtomicBool(false, lock: .sharedGlobal)
    
    // This property should only be accessed with unfairLock.
    private var willBecomeReadyTasks = [ReadyTask]()

    // This property should only be accessed with unfairLock.
    private var didBecomeReadySyncTasks = [ReadyTask]()

    // This property should only be accessed with unfairLock.
    private var didBecomeReadyAsyncTasks = [ReadyTask]()

    // MARK: CAUTION: Remove this before you go testing
    private var mockState: Bool  = false
    public func MockSetFlagReady(appReady:Bool = false) { mockState = appReady }
    
    
    @objc
    public var isSet: Bool {
        if mockState { true }
        else { flag.get() }
    }
    
    @MainActor
    public func runNowOrWhenAppWillBecomeReady(
        _ readyBlock: @escaping ReadyBlock,
        label: String? = nil
    ) {
        let task = ReadyTask(label: label, block: readyBlock)
        
        let didEnqueue: Bool = {
            unfairLock.withLock {
                guard !isSet else {
                    return false
                }
                willBecomeReadyTasks.append(task)
                return true
            }
        }()
        
        if !didEnqueue {
            // We perform the block outside unfairLock to avoid deadlock.
            BenchManager.bench(
                title: self.name + ".willBecomeReady " + task.displayLabel,
                logIfLongerThan: Self.blockLogDuration,
                logInProduction: true
            ) {
                autoreleasepool {
                    task.block()
                }
            }
        }
    }
    
    
    @MainActor
    public func runNowOrWhenDidBecomeReadySync(
        _ readyBlock: @escaping ReadyBlock,
        label: String? = nil
    ) {
        let task = ReadyTask(label: label, block: readyBlock)
        
        let didEnqueue: Bool = {
            unfairLock.withLock {
                guard !isSet else {
                    return false
                }
                didBecomeReadySyncTasks.append(task)
                return true
            }
        }()
        
        if !didEnqueue {
            // We perform the block outside unfairLock to avoid deadlock.
            BenchManager.bench(
                title: self.name + ".didBecomeReady " + task.displayLabel,
                logIfLongerThan: Self.blockLogDuration,
                logInProduction: true
            ) {
                autoreleasepool {
                    task.block()
                }
            }
        }
    }
    
    
    @MainActor
    public func runNowOrWhenDidBecomeReadyAsync(
        _ readyBlock: @escaping ReadyBlock,
        label: String? = nil
    ) {
        let task = ReadyTask(label: label, block: readyBlock)
        
        let didEnqueue: Bool = {
            unfairLock.withLock {
                guard !isSet else {
                    return false
                }
                didBecomeReadyAsyncTasks.append(task)
                return true
            }
        }()
        
        if !didEnqueue {
            // We perform the block outside unfairLock to avoid deadlock.
            BenchManager.bench(
                title: self.name + ".didBecomeReadySilent" + task.displayLabel,
                logIfLongerThan: Self.blockLogDuration,
                logInProduction: true
            ) {
                autoreleasepool {
                    task.block()
                }
            }
        }
    }
    
    @MainActor
    public func setIsReady() {
        guard let tasksToPerform = tryToSetFlag() else {
            return
        }
        PropeLog.info("\(self.name)")
        
        let willBecomeReadyTasks = tasksToPerform.willBecomeReadyTasks
        let didBecomeReadySyncTasks = tasksToPerform.didBecomeReadySyncTasks
        let didBecomeReadyAsyncTasks = tasksToPerform.didBecomeReadyAsyncTasks
        
        
        // We bench the blocks individually and as a group.
        BenchManager.bench(title: self.name + ".willBecomeReady group",
                           logIfLongerThan: Self.groupLogDuration,
                           logInProduction: true) {
            for task in willBecomeReadyTasks {
                BenchManager.bench(
                    title: self.name + ".willBecomeReady " + task.displayLabel,
                    logIfLongerThan: Self.blockLogDuration,
                    logInProduction: true
                ) {
                    autoreleasepool {
                        task.block()
                    }
                }
            }
        }

        BenchManager.bench(
            title: self.name + ".didBecomeReady group",
            logIfLongerThan: Self.groupLogDuration,
            logInProduction: true
        ) {
            for task in didBecomeReadySyncTasks {
                BenchManager.bench(
                    title: self.name + ".didBecomeReady " + task.displayLabel,
                    logIfLongerThan: Self.blockLogDuration,
                    logInProduction: true
                ) {
                    autoreleasepool {
                        task.block()
                    }
                }
            }
        }

        self.performDidBecomeReadyAsyncTasks(didBecomeReadyAsyncTasks)
    }
    
    private struct TasksToPerform {
        let willBecomeReadyTasks: [ReadyTask]
        let didBecomeReadySyncTasks: [ReadyTask]
        let didBecomeReadyAsyncTasks: [ReadyTask]
    }
    
    private func tryToSetFlag() -> TasksToPerform? {
        unfairLock.withLock {
            guard flag.tryToSetFlag() else {
                // We can only set the flag once.  If it's already set,
                // ensure that
                propeAssertDebug(willBecomeReadyTasks.isEmpty)
                propeAssertDebug(didBecomeReadySyncTasks.isEmpty)
                propeAssertDebug(didBecomeReadyAsyncTasks.isEmpty)
                return nil
            }

            let tasksToPerform = TasksToPerform(
                willBecomeReadyTasks: self.willBecomeReadyTasks,
                didBecomeReadySyncTasks: self.didBecomeReadySyncTasks,
                didBecomeReadyAsyncTasks: self.didBecomeReadyAsyncTasks
            )
            self.willBecomeReadyTasks = []
            self.didBecomeReadySyncTasks = []
            self.didBecomeReadyAsyncTasks = []
            return tasksToPerform
        }
    }
    
    private func performDidBecomeReadyAsyncTasks(_ tasks: [ReadyTask]) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.025) { [weak self] in
            guard let self = self else {
                return
            }
            guard let task = tasks.first else {
                return
            }
            BenchManager.bench(
                title: self.name + ".didBecomeReadySilent " + task.displayLabel,
                logIfLongerThan: Self.blockLogDuration,
                logInProduction: true,
                block: task.block
            )

            let remainder = Array(tasks.suffix(from: 1))
            self.performDidBecomeReadyAsyncTasks(remainder)
        }
    }
    
}
