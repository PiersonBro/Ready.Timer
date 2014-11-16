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
    private let initialDuration: NSTimeInterval
    private var duration: NSTimeInterval
    private var block: ((elapsedTime: String) -> ())?
    private var completionBlock: ((completionStatus: CompletionStatus) -> ())?
    private var timerDidStart: Bool = false
    
    public enum CompletionStatus: String {
        // The timer is completely finished. It's not coming back, ever.
        case Finished = "Finished"
        // Temporarily pause the timer, holding on to the blocks given in activateWithBlock.
        case Paused = "Paused"
        // Reset the timer so it was like activateWithBlock was never called.
        case Reset = "Reset"
    }
    
    private var completionStatus: CompletionStatus?
    
    // Read only enum, the consumer can't set these states themselves.
    public enum Status: String {
        // The timer is currently running.
        case Running = "Running"
        // The timer is finished.
        case Finished = "Finished"
        // The timer is suspended, with the duration maintained.
        case Paused = "Paused"
        // Reset actually maps to Inactive as this is the initial state of the object before activateWithBlock is called.
        case Inactive = "Inactive"
    }
    
    public var status: Status {
        if let completionStatus = completionStatus {
            var rawValue = completionStatus.rawValue
            if completionStatus == .Reset {
                rawValue = "Inactive"
            }
            return Status(rawValue:rawValue)!
        } else if timerDidStart || timer.valid {
            return .Running
        } else {
            return .Inactive
        }
    }
    
    public init(duration: Int) {
        self.duration = Double(duration) * 60 + 1
        initialDuration = self.duration
    }

    func activateWithBlock(block: (elapsedTime: String) -> (), completionBlock: (completionStatus: CompletionStatus) -> ()) {
        self.block = block
        self.completionBlock = completionBlock
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        timerDidStart = true
    }
    
    func concludeWithStatus(status: CompletionStatus) {
        completionStatus = status
        completionBlock!(completionStatus: status)

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
    }
    
    func timerFired(timer: NSTimer) {
        if duration != -1 {
             self.block!(elapsedTime: formattedStringForDuration(duration--))
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
