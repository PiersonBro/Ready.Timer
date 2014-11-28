//
//  TimerController.swift
//  Timer
//
//  Created by E&Z Pierson on 10/31/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

@objc public class TimerController {
    private lazy var timer: NSTimer = {
        return NSTimer(timeInterval: 1, target: self, selector:"timerFired:", userInfo: nil, repeats: true)
    }()
    // The original amount of timer passed to the timer, in seconds.
    private let initialDuration: NSTimeInterval
    // The duration of the timer in seconds.
    private var duration: NSTimeInterval
    private var block: ((elapsedTime: String) -> ())?
    private var conclusionBlock: ((conclusionStatus: ConclusionStatusRead) -> ())?
    private var timerDidStart: Bool = false
    
    /// The cases of ConclusionStatus that can be set by the TimerController consumer.
    public enum ConclusionStatusWrite: String {
        /// Temporarily pause the timer, holding on to the blocks given in activateWithBlock.
        case Paused = "Paused"
        /// Reset the timer so it was like activateWithBlock was never called.
        case Reset = "Reset"
    }
    
    // The cases unique to ConclusionStatusRead (which at this point is only .Finished) can be read by consumers of TimerController, but cannot be set by them.
    public enum ConclusionStatusRead: String {
        case Finished = "Finished"
        case Paused = "Paused"
        case Reset = "Reset"
    }
    
    public typealias ConclusionStatus = ConclusionStatusRead
    
    private var conclusionStatus: ConclusionStatus?
    
    /// Read only enum, the consumer can't set these states themselves.
    public enum Status: String {
        /// The timer is currently running.
        case Running = "Running"
        /// The timer is finished.
        case Finished = "Finished"
        // The timer is suspended, with the duration maintained.
        case Paused = "Paused"
        /// Reset actually maps to Inactive as this is the initial state of the object before activateWithBlock is called.
        case Inactive = "Inactive"
    }
    
    public var status: Status {
        if let conclusionStatus = conclusionStatus {
            var rawValue = conclusionStatus.rawValue
            if conclusionStatus == .Reset {
                rawValue = "Inactive"
            }
            return Status(rawValue:rawValue)!
        } else if timerDidStart && timer.valid {
            return .Running
        } else {
            return .Inactive
        }
    }
    
    /// Initialize a TimerController object.
    /// This doesn't start the timer instead,call activateWithBlock.
    ///
    /// Duration - In Minutes, meaning that duration is multiplied by 60.
    ///            If you need to have a timer in seconds just divde seconds by 60.
    public init(duration: Double) {
        self.duration = duration * 60 + 1
        initialDuration = self.duration
    }
    
    public init(duration: Int) {
        self.duration = Double(duration) * 60 + 1
        initialDuration = self.duration
    }

    public func activateWithBlock(block: (elapsedTime: String) -> (), conclusionBlock: (conclusionStatus: ConclusionStatus) -> ()) {
        if conclusionStatus != nil {
            conclusionStatus = nil
        }
        
        self.block = block
        self.conclusionBlock = conclusionBlock
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        timerDidStart = true
    }
    
    public func concludeWithStatus(status: ConclusionStatusWrite) {
        concludeWithStatus(ConclusionStatus(rawValue:status.rawValue)!)
    }
    
    private func concludeWithStatus(status: ConclusionStatusRead) {
        conclusionStatus = status

        switch status {
            case .Finished:
                duration = 0.0
            case .Reset:
                duration = initialDuration
            case .Paused:
                break
        }
        timer.invalidate()
        timer = NSTimer(timeInterval: 1, target: self, selector:"timerFired:", userInfo: nil, repeats: true)
        conclusionBlock!(conclusionStatus: status)
    }
    
    func timerFired(timer: NSTimer) {
        let time = duration--
        if duration != -1 {
             self.block!(elapsedTime: formattedStringForDuration(time))
        } else {
            concludeWithStatus(.Finished)
        }
    }
    
    private func formattedStringForDuration(duration: NSTimeInterval) -> String {
        let date = NSDate(timeInterval: duration, sinceDate: NSDate())
        let calendar =  NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit =  NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        let components = calendar.components(unitFlags, fromDate:NSDate(), toDate:date, options: NSCalendarOptions.allZeros)
        
        let minute = components.minute
        var second = ""
       
        if components.second < 10 {
            second = "0\(components.second)"
        } else {
            second = "\(components.second)"
        }

        return "\(minute):\(second)"
    }
}
