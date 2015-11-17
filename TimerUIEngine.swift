//
//  TimerUIEngine.swift
//  Timer
//
//  Created by E&Z Pierson on 9/19/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import UIKit
import TimerKit

protocol TimerUIEngineType {
    typealias Segment: SegmentType
    // FIXME: Shouldn't this just be a property? Swift is either broken or my mental model is. :/
    typealias Configuration: UIConfigurationType
    var segment: Segment { get }
    var configuration: Configuration  { get }
    init(segment: Segment, viewController: TimerViewControllerType)
    
    func buttonTapped()
    func doubleTapped()
    // This function is always called but it may not always be obeyed.
    func userFinished()
}

extension TimerUIEngineType where Segment.SegmentTimer.Status == TimerStatus {
    var initialDisplayText: String {
        return initialDisplayTextForStatus(segment.timer.status, timer: segment.timer)
    }
}

extension TimerUIEngineType where Segment.SegmentTimer.Status == OvertimeStatus {
    var initialDisplayText: String {
        let status: TimerStatus
        if segment.timer.status == .Paused {
            status = .Paused
        } else if segment.timer.status == .Inactive {
            status = .Inactive
        } else if segment.timer.status == .Finished {
            status = .Finished
        } else {
            fatalError("Inconsistent State")
        }

        return initialDisplayTextForStatus(status, timer: segment.timer)
    }
}

private func initialDisplayTextForStatus<T: TimerType>(status: TimerStatus, timer: T) -> String {
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

final class OvertimeUIEngine<T: SegmentType where T.SegmentTimer == OvertimeTimer>: TimerUIEngineType {
    typealias Segment = T
    typealias Configuration = OvertimeTimerUIConfiguration
    let segment: Segment
    let configuration = Configuration()
    private let timer: Segment.SegmentTimer
    private let viewController: TimerViewControllerType
    private var state: TimerButtonState? = nil
    
    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        self.viewController = viewController
        timer = segment.timer
        viewController.setTimerLabelText(initialDisplayText)
    }
    
    private var shouldCancel = false
    private var shouldResume = false
    func buttonTapped() {
        if shouldResume {
            changeTimerToState(.Resume)
            shouldResume = false
            shouldPause = true
            return
        }
        
        if shouldCancel {
            shouldCancel = false
            changeTimerToState(.Cancel)
        } else {
            shouldCancel = true
            changeTimerToState(.Start)
        }
    }
    
    private var shouldPause = true
    func doubleTapped() {
        if shouldPause {
            changeTimerToState(.Pause)
            shouldPause = false
            shouldResume = true
        } else {
            changeTimerToState(.Resume)
            shouldPause = true
        }
    }
    
    private func changeTimerToState(state: TimerButtonState) {
        if state == .Start || state == .Resume {
            timer.onTick { elapsedTime in
                self.viewController.setTimerLabelText(.formattedStringForDuration(elapsedTime))
            }.onConclusion { conclusionStatus in
                switch conclusionStatus {
                    case .Overtime:
                        self.viewController.timerDidFinish()
                    case .Reset:
                        self.viewController.setTimerLabelText("\(self.timer.startingTimeInMinutes!):00")
                    default:
                        break
                }
            }.activate()
        } else if state == .Cancel {
            timer.concludeWithStatus(.Reset)
        } else if state == .Pause {
            timer.concludeWithStatus(.Pause)
        }
        
        let timerStateToUpdateWorldWith = { () -> TimerButtonState? in
            switch state {
                case .Start:
                    return .Cancel
                case .Resume:
                    return .Cancel
                case .Pause:
                    shouldResume = true
                    return .Resume
                case .Cancel:
                    return .Start
                case .Suspend:
                    return nil
            }

        }()

        if let timerStateToUpdateWorldWith = timerStateToUpdateWorldWith {
            viewController.setTimerButtonText(timerStateToUpdateWorldWith.rawValue)
        }
    }
    
    func userFinished() {
        timer.concludeWithStatus(.Finish)
    }
}
