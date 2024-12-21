//
//  Atomics.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import SwiftUI
import Combine



// AtomicPropertyTemplate
@propertyWrapper
class AtomicProperty<T: Equatable & Codable>: ObservableObject {
    private var value: T
    private let queue: DispatchQueue = DispatchQueue(label: "com.fgbs.atomics", qos: .userInteractive)
    @Published private(set) var _value: T

    init(wrappedValue: T) {
        self.value = wrappedValue
        self._value = wrappedValue
    }

    var wrappedValue: T {
        get {
            queue.sync {
                return self.value
            }
        }
        set {
            queue.sync {
                self.value = newValue
                self._value = newValue //Important: Publish update
            }
        }
    }
    
    public func mutate(_ mutation: (inout T) -> Void) {
            return queue.sync { mutation(&value) }
    }
}

extension AtomicProperty where T == Int {
    static func ==(lhs: AtomicProperty<Int>, rhs: AtomicProperty<Int>) -> Bool {
        lhs.value == rhs.value
    }
}


extension AtomicProperty where T == UInt {
    static func ==(lhs: AtomicProperty<UInt>, rhs: AtomicProperty<UInt>) -> Bool {
        lhs.value == rhs.value
    }
}


// Add similar extensions for other types
extension AtomicProperty where T == Bool {
    static func ==(lhs: AtomicProperty<Bool>, rhs: AtomicProperty<Bool>) -> Bool {
        lhs.value == rhs.value
    }
}

extension AtomicProperty where T == CGFloat {
    static func ==(lhs: AtomicProperty<CGFloat>, rhs: AtomicProperty<CGFloat>) -> Bool {
        lhs.value == rhs.value
    }
}

extension AtomicProperty where T == Double {
    static func ==(lhs: AtomicProperty<Double>, rhs: AtomicProperty<Double>) -> Bool {
        lhs.value == rhs.value
    }
}

extension AtomicProperty where T == String {
    static func ==(lhs: AtomicProperty<String>, rhs: AtomicProperty<String>) -> Bool {
        lhs.value == rhs.value
    }
}

// Example for a custom struct
struct CustomStruct: Equatable, Codable {
    let id: String
    let value: Int

    static func == (lhs: CustomStruct, rhs: CustomStruct) -> Bool {
        return lhs.id == rhs.id && lhs.value == rhs.value
    }
    
    init(id: String, value: Int){
        self.id = id
        self.value = value
    }
}
extension AtomicProperty where T == CustomStruct {
  static func ==(lhs: AtomicProperty<CustomStruct>, rhs: AtomicProperty<CustomStruct>) -> Bool {
        lhs.value == rhs.value
    }
}




/*
 
 //// Tests for atomic props
 
 
 
 
 */
import SwiftUI

class BankAccount {
    @AtomicProperty var balance: Double = 1000.0
    @State var nonAtomicBalance: Double = 1000.0
    
    func deposit(amount: Double) {
        balance +=  amount
        
    }
    
    func depositNonAtomic(amount: Double) {
        nonAtomicBalance += amount
    }
    
    func withdraw(amount: Double) {
        balance -= amount
    }
    func withdrawNonAtomic(amount: Double) {
        nonAtomicBalance -= amount
    }
}

struct AtomicsView: View {
    @StateObject var intProperty = AtomicProperty<Int>(wrappedValue: 0)
    @StateObject var stringProperty = AtomicProperty<String>(wrappedValue: "Initial String")

    //Example for custom structs
    @StateObject var customStructProperty = AtomicProperty<CustomStruct>(wrappedValue: CustomStruct(id: "123", value: 456))
    
    let account = BankAccount()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print("Concurrently executing with atomic props: ")
                    
                    DispatchQueue.concurrentPerform(iterations: 10) { _ in
                        account.deposit(amount: 10.0)
                        print(account.balance)
                        account.withdraw(amount: 5.0)
                        print(account.balance)
                    }
                    let finalBalance = account.balance
                    print("Final Balance: \(finalBalance)")
                    
                }) {
                    Label("Atomic" , systemImage: "circle.hexagongrid.circle.fill").fontWeight(.bold)
                          .padding(10)
                      .foregroundColor(.white)
                      .background(.green,
                         in: RoundedRectangle(cornerRadius: 15))
                }
                Button(action: {
                    print("Concurrently executing with nonatomic props: ")
                    DispatchQueue.concurrentPerform(iterations: 10) { _ in
                        account.depositNonAtomic(amount: 10.0)
                        print(account.nonAtomicBalance)
                        account.withdrawNonAtomic(amount: 5.0)
                        print(account.nonAtomicBalance)
                    }
                    let finalBalance = account.balance
                    print("Final Balance: \(account.nonAtomicBalance)")
                    
                }) {
                    Label("Regular" , systemImage: "circle.hexagongrid.circle").fontWeight(.bold)
                          .padding(10)
                      .foregroundColor(.white)
                      .background(.orange,
                         in: RoundedRectangle(cornerRadius: 15))
            }
            }
              
    
            Text("Int Value: \(intProperty._value)")
            Button("Increment Int") {
                intProperty.wrappedValue += 1
            }
            Text("String Value:\n \(stringProperty._value)")
            Button("Change String") {
                stringProperty.wrappedValue = UUID().uuidString
            }

            
        }
    }
}

/*
struct AtomicsView_Preview : PreviewProvider {
    static var previews: some View {
        AtomicsView()
    }
}
*/
