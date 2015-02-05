//
//  TimerController.swift
//  Timer
//
//  Created by E&Z Pierson on 10/31/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

public class TimerController<T: TimerType where T.Status.RawValue == String>: TimerControllerType, TimerDelegate {
    public typealias Status = T.Status
    public var status: Status {
        if let conclusionStatus = conclusionStatus {
            var rawValue = conclusionStatus.rawValue
            if conclusionStatus == .Reset {
                rawValue = TimerStatus.Inactive.rawValue
            }
            
            return Status(rawValue: rawValue)!
        } else if running {
            return Status(rawValue: "Running")!
        } else {
            return Status(rawValue: "Inactive")!
        }
    }
    
    private var conclusionStatus: ConclusionStatus?
    
    public let timer: T
    private var statusBlock: StatusBlock?
    private var conclusionBlock: ConclusionBlock?
    
    private var keepDuration: Bool = false
    private var running = false
    
    public init(timer: T) {
        self.timer = timer
        self.timer.controller = self
    }
    
    public func activateWithBlock(block: StatusBlock, conclusionBlock: ConclusionBlock?) {
        statusBlock = block
        self.conclusionBlock = conclusionBlock
        conclusionStatus = nil
        running = true
        
        timer.activate(keepingDurationIfPossible: keepDuration)
    }
    
    public func concludeWithStatus(status: ConclusionStatusWrite) {
        concludeWithStatus(ConclusionStatus(rawValue: status.rawValue)!)
    }
    
    private func concludeWithStatus(status: ConclusionStatus) {
        running = false
        conclusionStatus = status
        if status == .Paused {
            keepDuration = true
        }
        
        timer.deactivate()
        conclusionBlock?(conclusionResult: ConclusionResult(conclusionStatus: status, totalTime: nil))
    }
    
    public func finished() {
        concludeWithStatus(.Finished)
    }
    
    public func continueWithDuration(duration: NSTimeInterval) {
        statusBlock!(elapsedTime: String.formattedStringForDuration(duration))
    }
}
