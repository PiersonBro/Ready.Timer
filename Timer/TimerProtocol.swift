//
//  TimerProtocol.swift
//  Timer
//
//  Created by E&Z Pierson on 12/1/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

/// The cases of ConclusionStatus that can be set by the TimerProtocol.
public enum ConclusionStatusWrite: String {
    /// Temporarily pause the timer, holding on to the blocks given in activateWithBlock.
    case Paused = "Paused"
    /// Reset the timer so it was like activateWithBlock was never called.
    case Reset = "Reset"
    // Reset the timer's duration to the last paused duration, if the timer was not paused, reset to the logical idea of zero for the given timer.
    case ResetToPaused = "ResetToPaused"
}


/// Includes all the cases of ConclusionStatusWrite, as well as .Finished
/// --which can not be set by consumers of TimerProtocol, only read.
public enum ConclusionStatus: String {
    case Finished = "Finished"
    case Paused = "Paused"
    case Reset = "Reset"
    case ResetToPaused = "ResetToPaused"
}

/// Read only enum, the consumer can't set these states themselves.
public enum TimerStatus: String {
    /// The timer is currently running.
    case Running = "Running"
    /// The timer is finished.
    case Finished = "Finished"
    // The timer is suspended, with the current duration maintained. Call activate with block to resume the timer.
    case Paused = "Paused"
    /// Reset actually maps to Inactive as this is the initial state of the object before activateWithBlock is called.
    case Inactive = "Inactive"
}

public struct ConclusionResult {
    public let conclusionStatus: ConclusionStatus
    // This only occurs for countUp Timers.
    public let totalTime: NSTimeInterval?
}

public typealias StatusBlock = (elapsedTime: String) -> ()
public typealias ConclusionBlock = (conclusionResult: ConclusionResult) -> ()

public protocol TimerControllerType {
    var status: TimerStatus { get }

    func activateWithBlock(block: StatusBlock, conclusionBlock: ConclusionBlock?)
    
    func concludeWithStatus(status: ConclusionStatusWrite)
}

public extension String {

    public static func formattedStringForDuration(duration: NSTimeInterval) -> String {
        let minute = Int(duration) / 60
        let second = Int(duration) % 60
        var secondString = ""

        if second < 10 {
            secondString = "0\(second)"
        } else {
            secondString = "\(second)"
        }
        
        return "\(minute):\(secondString)"
    }
}

