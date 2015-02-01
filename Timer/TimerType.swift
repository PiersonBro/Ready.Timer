//
//  Timer.swift
//  Timer
//
//  Created by E&Z Pierson on 1/12/15.
//  Copyright (c) 2015 E&Z Pierson. All rights reserved.
//

import Foundation

public protocol TimerDelegate {
    func continueWithDuration(duration: NSTimeInterval)
    func finished()
}

public protocol TimerType {
    var controller: TimerDelegate? {get set}
    func activate(#keepingDurationIfPossible: Bool)
    func deactivate()
}

public class CountDownTimer: TimerType {
    private var timer: NSTimer?

    public var duration: NSTimeInterval
    public let initialDuration: NSTimeInterval
    public var controller: TimerDelegate?
    
    public init(durationInMinutes: NSTimeInterval) {
        duration = durationInMinutes * 60
        initialDuration = durationInMinutes * 60
    }
    
    public func activate(#keepingDurationIfPossible: Bool) {
        if !keepingDurationIfPossible {
            duration = initialDuration
        }
       
        timer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        timer?.tolerance = 0.0
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    public func deactivate() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFired(timer: NSTimer) {
        let time = --duration
        
        if time != -1 {
            controller?.continueWithDuration(time)
        } else {
            controller?.finished()
        }
    }
    
}

public class CountUpTimer: TimerType {
    private lazy var timer: NSTimer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    
    public var controller: TimerDelegate?
    public let upperLimit: NSTimeInterval
    public var duration: NSTimeInterval = 0
    
    public init(upperLimitInMinutes: NSTimeInterval) {
        upperLimit = upperLimitInMinutes * 60
    }
    
    public func deactivate() {
        timer.invalidate()
    }
    
    public func activate(#keepingDurationIfPossible: Bool) {
        if !keepingDurationIfPossible {
           duration = 0
        }
        
        timer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    @objc private func timerFired(timer: NSTimer) {
        let time = ++duration
        
        if duration <= upperLimit {
            controller?.continueWithDuration(duration)
        } else {
            controller?.finished()
        }
    }
}

public class DebtTimer: TimerType, TimerDelegate {
    public var controller: TimerDelegate?
    
    private let countDownTimer: CountDownTimer
    private let countUpTimer: CountUpTimer
    /// If true, the timer is counting down, if false the timer is counting up, (and in debt). If nil, the timer is not counting.
    private var countingDown: Bool? = nil
    // Consider a generic type here for status
    // public let status: DebtTimerConclusionStatus
    
    public init(durationInMinutes: NSTimeInterval) {
        countDownTimer = CountDownTimer(durationInMinutes: durationInMinutes)
        countUpTimer = CountUpTimer(upperLimitInMinutes: durationInMinutes)
        
        countDownTimer.controller = self
        countUpTimer.controller = self
    }
    
    public func activate(#keepingDurationIfPossible: Bool) {
        switch countingDown {
            case .None:
                countDownTimer.activate(keepingDurationIfPossible: keepingDurationIfPossible)
                countingDown = true
            case .Some(true):
                countDownTimer.activate(keepingDurationIfPossible: keepingDurationIfPossible)
            case .Some(false):
               countUpTimer.activate(keepingDurationIfPossible: keepingDurationIfPossible)
            default:
                break
        }
    }
    
    public func deactivate() {
        switch countingDown {
            case .Some(true):
                countDownTimer.deactivate()
            case .Some(false):
                countUpTimer.deactivate()
            default:
                break
        }
    }
    
    public func continueWithDuration(duration: NSTimeInterval) {
        controller?.continueWithDuration(duration)
    }
    
    public func finished() {
        if countingDown == false {
            return
        }
        
        countingDown = false
        controller?.finished()
    }
}
