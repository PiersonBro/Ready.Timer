//
//  Segments.swift
//  Timer
//
//  Created by E&Z Pierson on 9/13/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

struct Round: Equatable {
    typealias OvertimeArray = [OvertimeSegment?]
    typealias InfiniteTimerArray = [InfiniteSegment?]
    typealias CountUpTimerArray = [CountUpSegment?]
    typealias CountDownTimerArray = [CountDownSegment?]
    typealias CountUpSegmentReferenceArray = [CountUpSegmentReference?]
    
    let segmentProxies: [SegmentProxy?]
    let name: String
    
    init(first: OvertimeArray, second: InfiniteTimerArray = [], third: CountUpTimerArray = [], fourth: CountDownTimerArray = [], fifth: CountUpSegmentReferenceArray = [], name: String) {
        self.name = name
        let count: Int
        var overtimeTimer: OvertimeArray
        var infiniteTimer: InfiniteTimerArray
        var countUpTimer: CountUpTimerArray
        var countDownTimer: CountDownTimerArray
        var countUpSegmentReference: CountUpSegmentReferenceArray
        
        if !first.isEmpty {
            count = first.count
        } else if !second.isEmpty {
            count = second.count
        } else if !third.isEmpty {
            count = third.count
        } else if !fourth.isEmpty {
            count = fourth.count
        } else if !fifth.isEmpty {
            count = fifth.count
        } else {
            fatalError("Cannot pass four empty arrays to `Round`.")
        }
                
        if first.isEmpty {
            overtimeTimer = Array(count: count, repeatedValue: nil)
        } else {
            overtimeTimer = first
        }
        
        if second.isEmpty {
            infiniteTimer = Array(count: count, repeatedValue: nil)
        } else {
            infiniteTimer = second
        }
        
        if third.isEmpty {
            countUpTimer = Array(count: count, repeatedValue: nil)
        } else {
            countUpTimer = third
        }
        
        if fourth.isEmpty {
            countDownTimer = Array(count: count, repeatedValue: nil)
        } else {
            countDownTimer = fourth
        }
        
        if fifth.isEmpty {
            countUpSegmentReference = Array(count: count, repeatedValue: nil)
        } else {
            countUpSegmentReference = fifth
        }
        
        
        segmentProxies = (0..<count).map { _ -> SegmentProxy? in
            Round.nextSpeech(&overtimeTimer, infiniteTimer: &infiniteTimer, countUpTimer: &countUpTimer, countDownTimer: &countDownTimer, countUpSegmentReference: &countUpSegmentReference)
        }
    }
    
    private static func nextSpeech(inout overtimeTimer: OvertimeArray, inout infiniteTimer: InfiniteTimerArray, inout countUpTimer: CountUpTimerArray, inout countDownTimer: CountDownTimerArray, inout countUpSegmentReference: CountUpSegmentReferenceArray) -> SegmentProxy? {
        let first = overtimeTimer.first
        let second = infiniteTimer.first
        let third = countUpTimer.first
        let fourth = countDownTimer.first
        let fifth = countUpSegmentReference.first

        guard let firstSegment = first, secondSegment = second, thirdSegment = third, fourthSegment = fourth, fifthSegment = fifth else {
            return nil
        }
        
        overtimeTimer.removeFirst()
        infiniteTimer.removeFirst()
        countUpTimer.removeFirst()
        countDownTimer.removeFirst()
        countUpSegmentReference.removeFirst()
        
        let valueOne = first.flatMap{_ in true}
        let valueTwo = second.flatMap{ _ in true}
        let valueThree = third.flatMap{_ in true}
        let valueFour = fourth.flatMap { _ in true}
        let valueFive = fifth.flatMap {_ in true}
        
        let values = [valueOne, valueTwo, valueThree, valueFour, valueFive].filter{$0 == true}
        
        if values.count != 0 {
            return SegmentProxy(segments: (firstSegment, secondSegment, thirdSegment, fourthSegment, fifthSegment))
        } else {
            return nil
        }
    }
    
    func resetReferenceSegments() {
        segmentProxies.map {
            $0?.segments
        }.filter {
            if let _ = $0!.4 {
                return true
            } else {
                return false
            }
        }.forEach {
            $0!.4!.reset()
        }
    }
}

func ==(rhs: Round, lhs: Round) -> Bool {
    let segmentProxiesEqual = zip(rhs.segmentProxies, lhs.segmentProxies).map { $0! == $1! }.filter {
        $0 == false
    }.count == 0
    
    return segmentProxiesEqual && rhs.name == lhs.name
}

extension Round: Hashable {
    var hashValue: Int {
        return segmentProxies.flatMap {
            $0?.hashValue
        }.reduce(0) { accumulator, value in
            return accumulator ^ value
        }
    }
}

struct SegmentProxy: Equatable {
    typealias Segments = (OvertimeSegment?, InfiniteSegment?, CountUpSegment?, CountDownSegment?, CountUpSegmentReference?)
    let segments: Segments
    
    var name: String {
        if let overtimeSegment = segments.0 {
            return overtimeSegment.name
        } else if let infiniteSegment = segments.1 {
            return infiniteSegment.name
        } else if let countUpSegment = segments.2 {
            return countUpSegment.name
        } else if let countDownSegment = segments.3 {
            return countDownSegment.name
        } else if let countUpSegmentReference = segments.4 {
            return countUpSegmentReference.name
        } else {
            fatalError()
        }
    }
    
    var kind: TimerKind {
        if let _ = segments.0 {
            return .OvertimeTimer
        } else if let _ = segments.1 {
            return .InfiniteTimer
        } else if let _ = segments.2 {
            return .CountUpTimer
        } else if let _ = segments.3 {
            return .CountDownTimer
        } else if let _ = segments.4 {
            return .CountUpTimerReference
        } else {
            fatalError()
        }
    }
    
    var sketch: TimerSketch {
        if let overtimeSegment = segments.0 {
            return overtimeSegment.sketch
        } else if let infiniteSegment = segments.1 {
            return infiniteSegment.sketch
        } else if let countUpSegment = segments.2 {
            return countUpSegment.sketch
        } else if let countDownSegment = segments.3 {
            return countDownSegment.sketch
        } else if let countUpSegmentReference = segments.4 {
            return countUpSegmentReference.sketch
        } else {
            fatalError()
        }
    }
    
    init(segments: Segments) {
        self.segments = segments
    }
}

//NOTE: `==` treats CountUpSegmentReference types as a normal value type. It doesn't have any concept at all about the (hacky) reset function. 
func ==(rhs: SegmentProxy, lhs: SegmentProxy) -> Bool {
    if let rhsOvertime = rhs.segments.0, let lhsOvertime = lhs.segments.0 {
        return rhsOvertime == lhsOvertime
    } else if let rhsInfiniteSegment = rhs.segments.1, let lhsInfiniteSegment = lhs.segments.1 {
        return rhsInfiniteSegment == lhsInfiniteSegment
    } else if let rhsCountUpSegment = rhs.segments.2, let lhsCountUpSegment = lhs.segments.2 {
        return rhsCountUpSegment == lhsCountUpSegment
    } else if let rhsCountDownSegment = rhs.segments.3, let lhsCountDownSegment = lhs.segments.3 {
        return rhsCountDownSegment == lhsCountDownSegment
    } else if let rhsCountUpSegmentReference = rhs.segments.4, let lhsCountUpSegmentReference = lhs.segments.4 {
        let x = rhsCountUpSegmentReference.name == lhsCountUpSegmentReference.name
        let y = rhsCountUpSegmentReference.sketch == lhsCountUpSegmentReference.sketch
        return x && y == true
    } else {
        return false
    }
}

extension SegmentProxy: Hashable {
    var hashValue: Int {
        if let overtimeSegment = segments.0 {
            return overtimeSegment.hashValue ^ name.hashValue
        } else if let infiniteSegment = segments.1 {
            return infiniteSegment.hashValue ^ name.hashValue
        } else if let countUpSegment = segments.2 {
            return countUpSegment.hashValue ^ name.hashValue
        } else if let countDownSegment = segments.3 {
            return countDownSegment.hashValue ^ name.hashValue
        } else if let countUpSegmentReference = segments.4 {
            return countUpSegmentReference.hashValue ^ name.hashValue
        } else {
            fatalError()
        }

    }
}
