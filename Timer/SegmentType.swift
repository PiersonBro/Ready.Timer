//
//  SegmentType.swift
//  Timer
//
//  Created by EandZ on 10/31/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

protocol SegmentType: Equatable {
    typealias SegmentTimer: TimerType
    
    var timer: SegmentTimer {get}
    var name: String {get}
}

// MARK: SegmentType Conformance
struct CountDownSegment: SegmentType {
    typealias SegmentTimer = Timer<CountDownBlueprint>
    
    let timer: SegmentTimer
    let name: String
}

func ==(lhs: CountDownSegment, rhs: CountDownSegment) -> Bool {
    return lhs.timer == rhs.timer && lhs.name == rhs.name
}

struct CountUpSegment: SegmentType {
    typealias SegmentTimer = Timer<CountUpBlueprint>
    
    let timer: SegmentTimer
    let name: String
}

func ==(lhs: CountUpSegment, rhs: CountUpSegment) -> Bool {
    return lhs.timer == rhs.timer && lhs.name == rhs.name
}


struct InfiniteSegment: SegmentType {
    typealias SegmentTimer = Timer<InfiniteBlueprint>
    
    let timer: SegmentTimer
    let name: String
}

func ==(lhs: InfiniteSegment, rhs: InfiniteSegment) -> Bool {
    return lhs.timer == rhs.timer && lhs.name == rhs.name
}

struct OvertimeSegment: SegmentType {
    typealias SegmentTimer = OvertimeTimer
    
    let timer: SegmentTimer
    let name: String
}

func ==(lhs: OvertimeSegment, rhs: OvertimeSegment) -> Bool {
    return lhs.timer == rhs.timer && lhs.name == rhs.name
}
