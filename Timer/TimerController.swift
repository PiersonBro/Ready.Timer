//
//  TimerController.swift
//  Timer
//
//  Created by E&Z Pierson on 10/31/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

@objc public class TimerController: TimerProtocol {
    private lazy var timer: NSTimer = {
        return NSTimer(timeInterval: 1, target: self, selector:"timerFired:", userInfo: nil, repeats: true)
    }()
    // The original amount of timer passed to the timer, in seconds.
    private let initialDuration: NSTimeInterval

    // The duration of the timer in seconds.
    private var duration: NSTimeInterval
    private var block: StatusBlock?
    private var conclusionBlock: ConclusionBlock?
    private var timerDidStart: Bool = false
    
    private var pausedDuration: NSTimeInterval?
    
    public var status: TimerStatus {
        if let conclusionStatus = conclusionStatus {
            var rawValue = conclusionStatus.rawValue
            if conclusionStatus == .Reset {
                rawValue = "Inactive"
            }
            return TimerStatus(rawValue:rawValue)!
        } else if timerDidStart && timer.valid {
            return .Running
        } else {
            return .Inactive
        }
    }

    private var conclusionStatus: ConclusionStatus?

    /// Initialize a TimerController object.
    /// This doesn't start the timer, instead call activateWithBlock.
    ///
    /// durationInMinutes - In Minutes --meaning that duration is multiplied by 60.
    ///            If you need to have a timer in seconds just divide seconds by 60.
    public init(durationInMinutes: NSTimeInterval) {
        duration = durationInMinutes * 60
        initialDuration = duration
    }
    
    public init(durationInSeconds: Int) {
        duration = NSTimeInterval(durationInSeconds)
        initialDuration = duration
    }

    public func activateWithBlock(block: StatusBlock, conclusionBlock: ConclusionBlock) {
        conclusionStatus = nil
        
        self.block = block
        self.conclusionBlock = conclusionBlock
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        timerDidStart = true
    }
    
    public func concludeWithStatus(status: ConclusionStatusWrite) {
        concludeWithStatus(ConclusionStatus(rawValue:status.rawValue)!)
    }
    
    private func concludeWithStatus(status: ConclusionStatus) {
        conclusionStatus = status

        switch status {
            case .Finished:
                duration = 0.0
            case .Reset:
                duration = initialDuration
            case .Paused:
                pausedDuration = duration
            case .ResetToPaused:
                duration = pausedDuration ?? initialDuration
        }
        
        timer.invalidate()
        timer = NSTimer(timeInterval: 1, target: self, selector:"timerFired:", userInfo: nil, repeats: true)

        conclusionBlock!(conclusionResult: ConclusionResult(conclusionStatus: status, totalTime: nil))
    }
    
    func timerFired(timer: NSTimer) {
        let time = duration--

        if duration != -1 {
             self.block!(elapsedTime: String.formattedStringForDuration(time))
        } else {
            concludeWithStatus(.Finished)
        }
    }
}
