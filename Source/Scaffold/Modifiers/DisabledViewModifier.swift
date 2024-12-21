//
//  DisabledViewModifier.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//

import SwiftUI

private struct DisabledViewModifier: ViewModifier {
    let isDisabled: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDisabled(isDisabled)
        } else {
            content.disabled(isDisabled)
        }
    }
}
