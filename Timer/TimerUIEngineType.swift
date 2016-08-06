//
//  TimerUIEngineType.swift
//  Timer
//
//  Created by E&Z Pierson on 9/19/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import UIKit
import TimerKit

protocol TimerUIEngineType {
    associatedtype Segment: SegmentType
    // FIXME: Shouldn't this just be a property? Swift is either broken or my mental model is. :/
    associatedtype Configuration: UIConfigurationType
    var segment: Segment { get }
    var timer: Segment.SegmentTimer { get }
    var configuration: Configuration  { get }
    init(segment: Segment, viewController: TimerViewControllerType)
    
    func buttonTapped()
    func doubleTapped()
    // This function is always called but it may not always be obeyed.
    func userFinished()
}

extension TimerUIEngineType where Segment.SegmentTimer.Status == TimerStatus {
    var initialDisplayText: String {
        return initialDisplayTextForStatus(timer.status, timer: timer)
    }
}

extension TimerUIEngineType where Segment.SegmentTimer.Status == OvertimeStatus {
    var initialDisplayText: String {
        let status: TimerStatus
        if timer.status == .Paused {
            status = .Paused
        } else if timer.status == .Inactive {
            status = .Inactive
        } else if timer.status == .Finished {
            status = .Finished
        } else {
            fatalError("Inconsistent State")
        }

        return initialDisplayTextForStatus(status, timer: timer)
    }
}

private func initialDisplayTextForStatus<T: TimerType>(_ status: TimerStatus, timer: T) -> String {
    if status == .Paused {
        if let pauseDuration = timer.pauseDuration {
            return .formattedStringForDuration(pauseDuration)
        } else {
            fatalError("Inconsistent State")
        }
    } else if status == .Inactive || status == .Finished {
        let displayText: String
        if let secondsStartingTime = timer.startingTimeInSeconds {
            displayText = .formattedStringForDuration(secondsStartingTime)
        } else if let startingTimeInMinutes = timer.startingTimeInMinutes {
            displayText = .formattedStringForDuration(startingTimeInMinutes * 60)
        } else {
            fatalError("Impossible!")
        }
        
        return displayText
    } else {
        fatalError("State is state")
    }
}

//FIXME: TimerButtonState Doesn't make any sense.
enum TimerButtonState: String {
    case Start
    case Cancel
    case Pause
    case Resume
    // This is only used for CountUpTimerUIEngine.
    case Suspend
}
