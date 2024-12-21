//
//  DBMigrateActivity.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 16/12/2024.
//

import Foundation
import QuartzCore

public class DBMigrateActivity : LaunchActivity, LaunchActivityTrackable {
    
    
    public var launchActivityTracker: LaunchActivityTracker?
    
    var startTime: CFTimeInterval?
    
    var completionTime: CFTimeInterval?
    
    private var trackingEnabled: Bool = false
    
    
    public init(launchActivityTracker: LaunchActivityTracker? = nil, startTime: CFTimeInterval? = nil, completionTime: CFTimeInterval? = nil) {
        self.launchActivityTracker = launchActivityTracker
        self.startTime = startTime
        self.completionTime = completionTime
    }
    
    public func launchEvent(with event: LaunchEvent) {
        self.event = .databaseMigrate
        launchActivityTracker?.currentEvent(with: event)
        debugPrint("Database migrate activity launched")
    }
    
    public func startTracking() {
        debugPrint("Start tracking requested")
        if !trackingEnabled  { trackingEnabled = true}
        
        
    }
    
    public func stopTracking() {
        debugPrint("Start tracking requested")
        trackingEnabled = false
    }
    
    //change this example to data, response, error
    //ResultCompletionHandler<[String : Data]>
    public func startLaunchActivity(with completionHandler: @escaping (Result<[String:Data], Error>) throws -> Void) {
        debugPrint("Start activity requested")
        self.startTime = CACurrentMediaTime() 
        if trackingEnabled {
            BenchManager.bench(title: "NotificationProcessActivity", logIfLongerThan: 0.2, logInProduction: true, block: {
                try? completionHandler(.success(bigEndiansOfPrimeNumbers(upTo: 2000)))
            })
        }
        do {
            try? completionHandler(.success(bigEndiansOfPrimeNumbers(upTo: 2000)))
            self.completionTime = CACurrentMediaTime()
        } catch (let error) {
            try? completionHandler(.failure(error))
        }
            
    }
    
   
    
    func bigEndiansOfPrimeNumbers(upTo: Int) -> [String : Data] {
        guard upTo > 1 else { return [:] } //Handle cases where upTo is too small
        var primes: [String : Data] = [:]
        for number in 2...upTo {
            if isPrime(number: number) {
                primes["\(number)"] = number.bigEndianData
                //primes.append(number : number.bigEndianData)
            }
        }
        return primes //.map { $0.bigEndianData }
    }
    
    func isPrime(number: Int) -> Bool {
        guard number > 1 else { return false } // 1 and numbers less than 2 are not prime

        // Optimized primality test
        if number % 2 == 0 && number != 2 {
            return false
        }

        //for i in 3..<Int(sqrt(Double(number)) + 1, stride(by: 2) {
        for i in stride(from: 3, through: Int(sqrt(Double(number)) + 1), by: 2) {
            if number % i == 0 {
                return false
            }
        }

        return true
    }
    
    func runAsyncTask(completion: @escaping (() -> Void)) {
            DispatchQueue.global().async {
                completion()
            }
        }

    
}
