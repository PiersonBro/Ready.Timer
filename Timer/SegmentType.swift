//
//  SegmentType.swift
//  Timer
//
//  Created by EandZ on 10/31/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

protocol SegmentType: Equatable, Hashable {
    associatedtype SegmentTimer: TimerType
    
    var name: String {get}
    var sketch: TimerSketch {get}
    
    func generateTimer() -> SegmentTimer
}

extension SegmentType {
    var hashValue: Int {
        return name.hashValue ^ sketch.hashValue
    }
}

// Similer to the concept of a `Blueprint` in Timer<T>, except it has a more specfic implementation.
//FIXME: Figure out a better way represent time.
struct TimerSketch {
    let durationInSeconds: Int?
    let durationInMinutes: Int?
    
    init(durationInSeconds: Int) {
        durationInMinutes = nil
        self.durationInSeconds = durationInSeconds
    }
    
    init(durationInMinutes: Int) {
        durationInSeconds = nil
        self.durationInMinutes = durationInMinutes
    }
}

extension TimerSketch: Equatable {}

func ==(lhs: TimerSketch, rhs: TimerSketch) -> Bool {
    if let leftDurationInSeconds = lhs.durationInSeconds, rightDurationInSeconds = rhs.durationInSeconds {
        return leftDurationInSeconds == rightDurationInSeconds
    } else if let leftDurationInMinutes = lhs.durationInMinutes, rightDurationInMinutes = rhs.durationInMinutes {
        return leftDurationInMinutes == rightDurationInMinutes
    } else {
        return lhs.durationInSeconds ?? (lhs.durationInMinutes! * 60) == rhs.durationInSeconds ?? (rhs.durationInMinutes! * 60)
    }
}

extension TimerSketch: Hashable {
    var hashValue: Int {
        return durationInMinutes?.hashValue ?? durationInSeconds!.hashValue
    }
}


// MARK: SegmentType Conformance
struct CountDownSegment: SegmentType {
    typealias SegmentTimer = Timer<CountDownBlueprint>
    
    let sketch: TimerSketch
    let name: String

    func generateTimer() -> SegmentTimer {
        let blueprint: CountDownBlueprint

        if let durationInSeconds = sketch.durationInSeconds {
            blueprint = CountDownBlueprint(countDownFromInSeconds: durationInSeconds)
        } else {
            blueprint = CountDownBlueprint(countDownFromInMinutes: sketch.durationInMinutes!)
        }
        
        return Timer(blueprint: blueprint)
    }
}

func ==(lhs: CountDownSegment, rhs: CountDownSegment) -> Bool {
    return lhs.sketch == rhs.sketch && lhs.name == rhs.name
}

struct CountUpSegment: SegmentType {
    typealias SegmentTimer = Timer<CountUpBlueprint>

    let sketch: TimerSketch
    let name: String

    func generateTimer() -> SegmentTimer {
        return createTimerFromSketch(sketch)
    }
}

private func createTimerFromSketch(sketch: TimerSketch) -> Timer<CountUpBlueprint> {
    let blueprint: CountUpBlueprint
    
    if let durationInSeconds = sketch.durationInSeconds {
        blueprint = CountUpBlueprint(upperLimitInSeconds: durationInSeconds)
    } else {
        blueprint = CountUpBlueprint(upperLimitInMinutes: sketch.durationInMinutes!)
    }
    
    return Timer(blueprint: blueprint)
}


func ==(lhs: CountUpSegment, rhs: CountUpSegment) -> Bool {
    return lhs.sketch == rhs.sketch && lhs.name == rhs.name
}

class CountUpSegmentReference: SegmentType {
    typealias SegmentTimer = Timer<CountUpBlueprint>
    
    let sketch: TimerSketch
    let name: String
    private var timer: SegmentTimer
    
    init(sketch: TimerSketch, name: String) {
        self.sketch = sketch
        self.name = name
        
        timer = createTimerFromSketch(sketch)
    }
    
    func generateTimer() -> SegmentTimer {
        return timer
    }
    
    func reset() {
        timer = createTimerFromSketch(sketch)
    }
}

func ==(lhs: CountUpSegmentReference, rhs: CountUpSegmentReference) -> Bool {
    return lhs.sketch == rhs.sketch && lhs.name == rhs.name && lhs.timer == rhs.timer
}

struct InfiniteSegment: SegmentType {
    typealias SegmentTimer = Timer<InfiniteBlueprint>

    let sketch: TimerSketch
    let name: String
    
    func generateTimer() -> SegmentTimer {
        return Timer(blueprint: InfiniteBlueprint())
    }
}

func ==(lhs: InfiniteSegment, rhs: InfiniteSegment) -> Bool {
    return lhs.name == rhs.name
}

struct OvertimeSegment: SegmentType {
    typealias SegmentTimer = OvertimeTimer
    
    let sketch: TimerSketch
    let name: String
    
    func generateTimer() -> SegmentTimer {
        if let durationInSeconds = sketch.durationInSeconds {
            return OvertimeTimer(timeLimitInSeconds: durationInSeconds)
        } else {
            return OvertimeTimer(timeLimitInMinutes: sketch.durationInMinutes!)
        }
    }
}

func ==(lhs: OvertimeSegment, rhs: OvertimeSegment) -> Bool {
    return lhs.sketch == rhs.sketch && lhs.name == rhs.name
}
