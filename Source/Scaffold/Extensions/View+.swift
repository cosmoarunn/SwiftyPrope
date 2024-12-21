//
//  View+.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//
import SwiftUI

extension View {
    
    public func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
            overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }

    public func customStroke(color: Color, width: CGFloat) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
    
    public func reflection(opacity: Double = 0.0, spacing: CGFloat = 0) -> some View {
        modifier(ReflectionModifier(opacity: opacity, spacing: spacing))
    }
    
}


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}


class ReloadViewObserver: ObservableObject {
    func reloadView() {
        objectWillChange.send()
    }
}







