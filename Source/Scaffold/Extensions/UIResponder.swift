//
//  UIResponder.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 13/12/2024.
//

import Foundation
import UIKit

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        // Passing `nil` to the to parameter of `sendAction` calls it on the firstResponder.
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc
    private func findFirstResponder() {
        UIResponder._currentFirstResponder = self
    }
}
