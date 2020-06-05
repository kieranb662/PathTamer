//
//  CalculateBoundingBox.swift
//  PathTamer
//
//  Created by Kieran Brown on 6/5/20.
//  Copyright © 2020 Kieran Brown. All rights reserved.
//

import Foundation
import bez
import SwiftUI


func calculateBoundingBox(path: String) -> CGSize {
    var lookupTable = [CGPoint]()
    let p: Path = Path(path) ?? Circle().path(in: .init(x: 0, y: 0, width: 1, height: 1))
    let elements = p.elements
    let threshold = 0.4
    var lastPoint: CGPoint = .zero
    var startingPoint: CGPoint = .zero
    let numOfDivisions: ClosedRange<Int> = 1...20
    
    for element in elements {
        switch element {
        case .move(let to):
            lookupTable.append(to)
            startingPoint = to
            lastPoint = to
        case .line(let to):
            numOfDivisions.forEach { (i) in
                let nextPossible = linearInterpolation(t: Float(i)/Float(numOfDivisions.upperBound), start: lastPoint, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
        case .quadCurve(let to, let control):
            numOfDivisions.forEach { (i) in
                let nextPossible = quadraticBezierInterpolation(t: Float(i)/Float(numOfDivisions.upperBound), start: lastPoint, control: control, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
        case .curve(let to, let control1, let control2):
            
            numOfDivisions.forEach { (i) in
                let nextPossible = cubicBezierInterpolation(t: Float(i)/Float(numOfDivisions.upperBound), start: lastPoint, control1: control1, control2: control2, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
        case .closeSubpath:
            numOfDivisions.forEach { (i) in
                let nextPossible = linearInterpolation(t: Float(i)/Float(numOfDivisions.upperBound), start: lastPoint, end: startingPoint)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
        }
    }
    
    let minX: CGFloat = lookupTable.map({$0.x}).min() ?? 0
    let maxX: CGFloat = lookupTable.map({$0.x}).max() ?? 0
    let minY: CGFloat = lookupTable.map({$0.y}).min() ?? 0
    let maxY: CGFloat = lookupTable.map({$0.y}).max() ?? 0
    
    return CGSize(width: maxX-minX, height: maxY-minY)
}
