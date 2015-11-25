//
//  Segments.swift
//  Timer
//
//  Created by E&Z Pierson on 9/13/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

struct Round {
    typealias OvertimeArray = [OvertimeSegment?]
    typealias InfiniteTimerArray = [InfiniteSegment?]
    typealias CountUpTimerArray = [CountUpSegment?]
    typealias CountDownTimerArray = [CountDownSegment?]
    
    let segmentProxies: [SegmentProxy?]
    let name: String
    
    init(first: OvertimeArray, second: InfiniteTimerArray = [], third: CountUpTimerArray = [], fourth: CountDownTimerArray = [], name: String) {
        self.name = name
        let count: Int
        var overtimeTimer: OvertimeArray
        var infiniteTimer: InfiniteTimerArray
        var countUpTimer: CountUpTimerArray
        var countDownTimer: CountDownTimerArray
        
        if !first.isEmpty {
            count = first.count
        } else if !second.isEmpty {
            count = second.count
        } else if !third.isEmpty {
            count = third.count
        } else if !fourth.isEmpty {
            count = fourth.count
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
        
        segmentProxies = (0..<count).map { _ -> SegmentProxy? in
            Round.nextSpeech(&overtimeTimer, infiniteTimer: &infiniteTimer, countUpTimer: &countUpTimer, countDownTimer: &countDownTimer)
        }
    }
    
    private static func nextSpeech(inout overtimeTimer: OvertimeArray, inout infiniteTimer: InfiniteTimerArray, inout countUpTimer: CountUpTimerArray, inout countDownTimer: CountDownTimerArray) -> SegmentProxy? {
        let first = overtimeTimer.first
        let second = infiniteTimer.first
        let third = countUpTimer.first
        let fourth = countDownTimer.first

        guard let firstTimer = first, secondTimer = second, thirdTimer = third, fourthTimer = fourth else {
            return nil
        }
        
        overtimeTimer.removeFirst()
        infiniteTimer.removeFirst()
        countUpTimer.removeFirst()
        countDownTimer.removeFirst()
        
        let valueOne = firstTimer.flatMap{_ in true}
        let valueTwo = secondTimer.flatMap{ _ in true}
        let valueThree = thirdTimer.flatMap{_ in true}
        let valueFour = fourthTimer.flatMap { _ in true}
        
        let values = [valueOne, valueTwo, valueThree, valueFour].filter{$0 == true}
        
        if values.count != 0 {
            return SegmentProxy(segments: (firstTimer, secondTimer, thirdTimer, fourthTimer))
        } else {
            return nil
        }
    }
}

struct SegmentProxy {
    typealias Segments = (OvertimeSegment?, InfiniteSegment?, CountUpSegment?, CountDownSegment?)
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
        } else {
            fatalError()
        }
    }

    init(segments: Segments) {
        self.segments = segments
    }
}
