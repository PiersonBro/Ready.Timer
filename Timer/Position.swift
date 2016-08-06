//
//  Position.swift
//  Timer
//
//  Created by E&Z Pierson on 12/18/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

public typealias PositionTuple = (xMultiplier: Float, yMultiplier: Float)

// The idea of Position is that you privately extend it with your own value.
public enum Position {
    case center(PositionTuple)
    case right(PositionTuple)
    case left(PositionTuple)
    case bottom(PositionTuple)
    
    // Convenience access to the associated values of the enum.
    var positionTuple: PositionTuple {
        switch (self) {
        case .center(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .right(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .left(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .bottom(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        }
    }
}

extension Position: Equatable {}

public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.positionTuple.xMultiplier == rhs.positionTuple.xMultiplier && lhs.positionTuple.yMultiplier == rhs.positionTuple.yMultiplier
}
