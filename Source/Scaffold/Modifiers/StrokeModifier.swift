//
//  StrokeModifier.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//
import SwiftUI

struct StrokeModifier : ViewModifier {
    
    
    private let id = UUID()
    var strokeSize: CGFloat = 1.0
    var strokeColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(Rectangle()
                .foregroundStyle(strokeColor)
                .mask({ outline(context: content) })
            )
            
    }
    
    func outline(context: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { layer in
                if let text = context.resolveSymbol(id: id) {
                    layer.draw(text, at: .init(x: size.width/2, y: size.height/2))
                }
            }
        } symbols: {
            context.tag(id)
                .blur(radius: strokeSize)
        }
    }
}
