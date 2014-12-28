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
    case Center(PositionTuple)
    case Right(PositionTuple)
    case Left(PositionTuple)
    case Bottom(PositionTuple)
    
    // Convenience access to the associated values of the enum.
    var positionTuple: PositionTuple {
        switch (self) {
        case .Center(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .Right(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .Left(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        case .Bottom(let xMultiplier, let yMultiplier):
            return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        }
    }
}
