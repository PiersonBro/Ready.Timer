//
//  CountUpTimerController.swift
//  Timer
//
//  Created by E&Z Pierson on 12/1/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

@objc public class CountUpTimerController: TimerProtocol {
    /// The how much time can elapse before the timer is finished, in seconds.
    private let upperLimit: Double?
    private var duration: NSTimeInterval = 0
    private var statusBlock: StatusBlock?
    private var conclusionBlock: ConclusionBlock?
    private lazy var timer: NSTimer = NSTimer(timeInterval: 1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    private var timerDidStart: Bool = false
    
    public var status: TimerStatus {
        if let conclusionStatus = conclusionStatus {
            var rawValue = conclusionStatus.rawValue
            if conclusionStatus == .Reset {
                rawValue = TimerStatus.Inactive.rawValue
            }
            return TimerStatus(rawValue: rawValue)!
        } else if timer.valid && timerDidStart {
            return .Running
        } else {
            return .Inactive
        }
    }
    
    private var conclusionStatus: ConclusionStatus?
    
    public init(upperLimitInMinutes: Double?) {
        upperLimit = upperLimitInMinutes
    }
    
    public init(upperLimitInSeconds: Int) {
        upperLimit = Double(upperLimitInSeconds)
    }
    
    public func activateWithBlock(block: StatusBlock, conclusionBlock: ConclusionBlock) {
        conclusionStatus = nil
        
        statusBlock = block
        self.conclusionBlock = conclusionBlock
 
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        timerDidStart = true
    }
    
    func timerFired(timer: NSTimer) {
        let time = duration++
        statusBlock!(elapsedTime: String.formattedStringForDuration(time))
        
        if let upperLimit = upperLimit {
            if time == upperLimit {
                concludeWithStatus(.Finished)
            }
        }
        
    }
    
    public func concludeWithStatus(status: ConclusionStatusWrite) {
        concludeWithStatus(ConclusionStatusRead(rawValue: status.rawValue)!)
    }

    private func concludeWithStatus(status: ConclusionStatusRead) {
        switch status {
            case .Finished:
                break
            case .Reset:
                duration = 0.0
            case .Paused:
                break
        }
        
        timer.invalidate()
        conclusionBlock!(conclusionResult: ConclusionResult(conclusionStatus: status, totalTime: duration))
    }
}
