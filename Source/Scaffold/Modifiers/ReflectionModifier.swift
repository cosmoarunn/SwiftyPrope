//
//  ReflectionModifier.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//

import SwiftUI
 
struct ReflectionModifier : ViewModifier {
    var opacity: Double
    var spacing: CGFloat
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            content
                .scaleEffect(-1)
                .scaleEffect(x: -1)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                )
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                )
                .opacity(opacity)
                .offset(y:spacing)
        }
    }
}
 
