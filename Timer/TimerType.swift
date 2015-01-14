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
    func conclude()
}

public protocol TimerType {
    var controller: TimerDelegate? {get set}
    func activate(#keepingDurationIfPossible: Bool)
    func deactivate()
}

@objc public class CountDownTimer: TimerType {
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
        
        if time != 0 {
            controller?.continueWithDuration(time)
        } else {
            controller?.conclude()
        }
    }
    
}

@objc public class CountUpTimer: TimerType {
    private lazy var timer: NSTimer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    
    public var controller: TimerDelegate?
    public let upperLimit: NSTimeInterval
    public var duration: NSTimeInterval = 0
    
    init(upperLimitInMinutes: NSTimeInterval) {
        upperLimit = upperLimitInMinutes * 60
    }
    
    public func deactivate() {
        timer.invalidate()
    }
    
    public func activate(#keepingDurationIfPossible: Bool) {
        if keepingDurationIfPossible {
           duration = 0
        }
        
        timer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    @objc private func timerFired(timer: NSTimer) {
        let time = ++duration
        
        if duration != upperLimit {
            controller?.continueWithDuration(duration)
        } else {
            controller?.conclude()
        }
    }
}
