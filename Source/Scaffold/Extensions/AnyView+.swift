//
//  AnyView+.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 21/12/2024.
//
import SwiftUI

extension AnyView: Hashable { //This is NOT generally recommended
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
}

//The == operator needs to be implemented as well. This implementation is simplistic
extension AnyView: Equatable { //This is NOT generally recommended
    public static func == (lhs: AnyView, rhs: AnyView) -> Bool {
        lhs.description == rhs.description
    }
}
