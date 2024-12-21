//
//  CG+.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import UIKit


public extension UIEdgeInsets {
    
    var isRTL: Bool {  false }
    
    init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat, isRTL: Bool) {
        
        self.init(top: top,
                  left: isRTL ? trailing : leading,
                  bottom: bottom,
                  right: isRTL ? leading : trailing)
    }

    init(hMargin: CGFloat, vMargin: CGFloat) {
        self.init(top: vMargin, left: hMargin, bottom: vMargin, right: hMargin)
    }

    init(margin: CGFloat) {
        self.init(top: margin, left: margin, bottom: margin, right: margin)
    }

    func plus(_ inset: CGFloat) -> UIEdgeInsets {
        var newInsets = self
        newInsets.top += inset
        newInsets.bottom += inset
        newInsets.left += inset
        newInsets.right += inset
        return newInsets
    }

    func minus(_ inset: CGFloat) -> UIEdgeInsets {
        plus(-inset)
    }

    var asSize: CGSize {
        CGSize(width: left + right,
               height: top + bottom)
    }
}

public extension NSDirectionalEdgeInsets {
    init(hMargin: CGFloat, vMargin: CGFloat) {
        self.init(top: vMargin, leading: hMargin, bottom: vMargin, trailing: hMargin)
    }

    init(margin: CGFloat) {
        self.init(top: margin, leading: margin, bottom: margin, trailing: margin)
    }
}

// MARK: -

public extension CGPoint {
    func toUnitCoordinates(viewBounds: CGRect, shouldClamp: Bool) -> CGPoint {
        CGPoint(x: (x - viewBounds.origin.x).inverseLerp(0, viewBounds.width, shouldClamp: shouldClamp),
                y: (y - viewBounds.origin.y).inverseLerp(0, viewBounds.height, shouldClamp: shouldClamp))
    }

    func toUnitCoordinates(viewSize: CGSize, shouldClamp: Bool) -> CGPoint {
        toUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize), shouldClamp: shouldClamp)
    }

    func fromUnitCoordinates(viewBounds: CGRect) -> CGPoint {
        CGPoint(x: viewBounds.origin.x + x.lerp(0, viewBounds.size.width),
                y: viewBounds.origin.y + y.lerp(0, viewBounds.size.height))
    }

    func fromUnitCoordinates(viewSize: CGSize) -> CGPoint {
        fromUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize))
    }

    func inverse() -> CGPoint {
        CGPoint(x: -x, y: -y)
    }

    func plus(_ value: CGPoint) -> CGPoint {
        CGPoint.add(self, value)
    }

    func plusX(_ value: CGFloat) -> CGPoint {
        CGPoint.add(self, CGPoint(x: value, y: 0))
    }

    func plusY(_ value: CGFloat) -> CGPoint {
        CGPoint.add(self, CGPoint(x: 0, y: value))
    }

    func minus(_ value: CGPoint) -> CGPoint {
        CGPoint.subtract(self, value)
    }

    func times(_ value: CGFloat) -> CGPoint {
        CGPoint(x: x * value, y: y * value)
    }

    func min(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function min() from this method.
        CGPoint(x: Swift.min(x, value.x),
                y: Swift.min(y, value.y))
    }

    func max(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function max() from this method.
        CGPoint(x: Swift.max(x, value.x),
                y: Swift.max(y, value.y))
    }

    var length: CGFloat {
        sqrt(x * x + y * y)
    }

    @inlinable
    func distance(_ other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    @inlinable
    func within(_ delta: CGFloat, of other: CGPoint) -> Bool {
        distance(other) <= delta
    }

    static let unit: CGPoint = CGPoint(x: 1.0, y: 1.0)

    static let unitMidpoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

    func applyingInverse(_ transform: CGAffineTransform) -> CGPoint {
        applying(transform.inverted())
    }

    func fuzzyEquals(_ other: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
        (x.fuzzyEquals(other.x, tolerance: tolerance) &&
            y.fuzzyEquals(other.y, tolerance: tolerance))
    }

    static func tan(angle: CGFloat) -> CGPoint {
        CGPoint(x: sin(angle),
                y: cos(angle))
    }

    func clamp(_ rect: CGRect) -> CGPoint {
        CGPoint(x: x.clamp(rect.minX, rect.maxX),
                y: y.clamp(rect.minY, rect.maxY))
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        left.plus(right)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x * right, y: left.y * right)
    }

    static func *= (left: inout CGPoint, right: CGFloat) {
        left.x *= right
        left.y *= right
    }
}
// MARK: -

// MARK: -
extension CGSize {
    @inlinable
    public static func ceil(_ size: CGSize) -> CGSize {
        CGSize(width: Darwin.ceil(size.width), height: Darwin.ceil(size.height))
    }

    @inlinable
    public static func floor(_ size: CGSize) -> CGSize {
        CGSize(width: Darwin.floor(size.width), height: Darwin.floor(size.height))
    }

    @inlinable
    public static func round(_ size: CGSize) -> CGSize {
        CGSize(width: Darwin.round(size.width), height: Darwin.round(size.height))
    }

    @inlinable
    public static func max(_ a: CGSize, _ b: CGSize) -> CGSize {
        CGSize(width: Swift.max(a.width, b.width), height: Swift.max(a.height, b.height))
    }

    @inlinable
    public static func scale(_ size: CGSize, factor: CGFloat) -> CGSize {
        CGSize(width: size.width * factor, height: size.height * factor)
    }

    @inlinable
    public static func add(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

extension CGPoint {
    @inlinable
    public static func add(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @inlinable
    public static func subtract(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @inlinable
    public static func scale(_ point: CGPoint, factor: CGFloat) -> CGPoint {
        CGPoint(x: point.x * factor, y: point.y * factor)
    }

    @inlinable
    public static func min(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: Swift.min(a.x, b.x), y: Swift.min(a.y, b.y))
    }

    @inlinable
    public static func max(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: Swift.max(a.x, b.x), y: Swift.max(a.y, b.y))
    }

    @inlinable
    public static func clamp01(_ point: CGPoint) -> CGPoint {
        CGPoint(x: CGFloat.clamp01(point.x), y: CGFloat.clamp01(point.y))
    }

    @inlinable
    public static func invert(_ point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }
}

extension CGRect {
    @inlinable
    public static func scale(_ rect: CGRect, factor: CGFloat) -> CGRect {
        CGRect(origin: CGPoint.scale(rect.origin, factor: factor),
               size: CGSize.scale(rect.size, factor: factor))
    }
}

public extension CGSize {
    var aspectRatio: CGFloat {
        guard self.height > 0 else {
            return 0
        }

        return self.width / self.height
    }

    var asPoint: CGPoint {
        CGPoint(x: width, y: height)
    }

    var ceil: CGSize {
        CGSize.ceil(self)
    }

    var floor: CGSize {
        CGSize.floor(self)
    }

    var round: CGSize {
        CGSize.round(self)
    }

    var abs: CGSize {
        CGSize(width: Swift.abs(width), height: Swift.abs(height))
    }

    var largerAxis: CGFloat {
        Swift.max(width, height)
    }

    var smallerAxis: CGFloat {
        min(width, height)
    }

    var isNonEmpty: Bool {
        width > 0 && height > 0
    }

    init(square: CGFloat) {
        self.init(width: square, height: square)
    }
    

    func plus(_ value: CGSize) -> CGSize {
        CGSize.add(self, value)
    }

    func max(_ other: CGSize) -> CGSize {
        return CGSize(width: Swift.max(self.width, other.width),
                      height: Swift.max(self.height, other.height))
    }

    static func square(_ size: CGFloat) -> CGSize {
        CGSize(width: size, height: size)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        left.plus(right)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width - right.width,
               height: left.height - right.height)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right,
               height: left.height * right)
    }
}

// MARK: -

public extension CGRect {

    var x: CGFloat {
        get {
            origin.x
        }
        set {
            origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            origin.y
        }
        set {
            origin.y = newValue
        }
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var topLeft: CGPoint {
        origin
    }

    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }

    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }

    func pinnedToVerticalEdge(of boundingRect: CGRect) -> CGRect {
        var newRect = self

        // If we're positioned outside of the vertical bounds,
        // we need to move to the nearest bound
        let positionedOutOfVerticalBounds = newRect.minY < boundingRect.minY || newRect.maxY > boundingRect.maxY

        // If we're position anywhere but exactly at the vertical
        // edges (left and right of bounding rect), we need to
        // move to the nearest edge
        let positionedAwayFromVerticalEdges = boundingRect.minX != newRect.minX && boundingRect.maxX != newRect.maxX

        if positionedOutOfVerticalBounds {
            let distanceFromTop = newRect.minY - boundingRect.minY
            let distanceFromBottom = boundingRect.maxY - newRect.maxY

            if distanceFromTop > distanceFromBottom {
                newRect.origin.y = boundingRect.maxY - newRect.height
            } else {
                newRect.origin.y = boundingRect.minY
            }
        }

        if positionedAwayFromVerticalEdges {
            let distanceFromLeading = newRect.minX - boundingRect.minX
            let distanceFromTrailing = boundingRect.maxX - newRect.maxX

            if distanceFromLeading > distanceFromTrailing {
                newRect.origin.x = boundingRect.maxX - newRect.width
            } else {
                newRect.origin.x = boundingRect.minX
            }
        }

        return newRect
    }
}

// MARK: -

public extension UIEdgeInsets {
    var totalWidth: CGFloat {
        left + right
    }

    var totalHeight: CGFloat {
        top + bottom
    }

    var totalSize: CGSize {
        CGSize(width: totalWidth, height: totalHeight)
    }

    var leading: CGFloat {
        get { isRTL ? right : left }
        set {
            if isRTL {
                right = newValue
            } else {
                left = newValue
            }
        }
    }

    var trailing: CGFloat {
        get { isRTL ? left : right }
        set {
            if isRTL {
                left = newValue
            } else {
                right = newValue
            }
        }
    }

    var isNonEmpty: Bool {
        left != 0 || right != 0 || top != 0 || bottom != 0
    }
}

// MARK: -
extension CGFloat {
    @inlinable
    public static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }

    @inlinable
    public static func clamp01(_ value: CGFloat) -> CGFloat {
        clamp(value, min: 0, max: 1)
    }

    @inlinable
    public static func lerp(left: CGFloat, right: CGFloat, alpha: CGFloat) -> CGFloat {
        (left * (1.0 - alpha)) + (right * alpha)
    }

    @inlinable
    public static func inverseLerp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        (value - min) / (max - min)
    }

    /// Ceil to an even number
    @inlinable
    public static func ceilEven(_ value: CGFloat) -> CGFloat {
        2.0 * Darwin.ceil(value * 0.5)
    }
}
public extension CGFloat {
    var pointsAsPixels: CGFloat {
        self * UIScreen.main.scale
    }

    // An epsilon is a small, non-zero value.
    //
    // This value is _NOT_ an appropriate tolerance for fuzzy comparison,
    // e.g. fuzzyEquals().
    static var epsilon: CGFloat {
        // ulpOfOne is the difference between 1.0 and the next largest CGFloat value.
        .ulpOfOne
    }
}

public extension CGFloat {
    func clamp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return CGFloat.clamp(self, min: minValue, max: maxValue)
    }

    func clamp01() -> CGFloat {
        return CGFloat.clamp01(self)
    }

    /// Returns a random value within the specified range with a fixed number of discrete choices.
    ///
    /// ```
    /// CGFloat.random(in: 0..10, choices: 2)  // => 5
    /// CGFloat.random(in: 0..10, choices: 2)  // => 0
    /// CGFloat.random(in: 0..10, choices: 2)  // => 5
    ///
    /// CGFloat.random(in: 0..10, choices: 10)  // => 8
    /// CGFloat.random(in: 0..10, choices: 10)  // => 4
    /// CGFloat.random(in: 0..10, choices: 10)  // => 0
    /// ```
    ///
    /// - Parameters:
    ///   - range: The range in which to create a random value.
    ///     `range` must be finite and nonempty.
    ///   - choices: The number of discrete choices for the result.
    /// - Returns: A random value within the bounds of `range`, constrained to the number of `choices`.
    static func random(in range: Range<CGFloat>, choices: UInt) -> CGFloat {
        let rangeSize = range.upperBound - range.lowerBound
        let choice = UInt.random(in: 0..<choices)
        return range.lowerBound + (rangeSize * CGFloat(choice) / CGFloat(choices))
    }

    // Linear interpolation
    func lerp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return CGFloat.lerp(left: minValue, right: maxValue, alpha: self)
    }

    // Inverse linear interpolation
    func inverseLerp(_ minValue: CGFloat, _ maxValue: CGFloat, shouldClamp: Bool = false) -> CGFloat {
        let value = CGFloat.inverseLerp(self, min: minValue, max: maxValue)
        return (shouldClamp ? CGFloat.clamp01(value) : value)
    }

    static let halfPi: CGFloat = CGFloat.pi * 0.5

    func fuzzyEquals(_ other: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        return abs(self - other) < tolerance
    }

    var square: CGFloat {
        return self * self
    }

    func average(_ other: CGFloat) -> CGFloat {
        (self + other) * 0.5
    }
}
