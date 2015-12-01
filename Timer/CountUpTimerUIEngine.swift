//
//  CountUpTimerUIEngine.swift
//  Timer
//
//  Created by EandZ on 11/3/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

final class CountUpTimerUIEngine: TimerUIEngineType {
    typealias Segment = CountUpSegment
    typealias Configuration = DefaultConfiguration
    let segment: Segment
    let configuration = Configuration()
    private let viewController: TimerViewControllerType
    private let timer: Segment.SegmentTimer
    private var state: TimerButtonState? = nil
    
    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        self.viewController = viewController
        timer = segment.timer
        viewController.setTimerLabelText(initialDisplayText)
    }
    
    private var shouldSuspend = false
    private var shouldResume = false
    func buttonTapped() {
        if shouldResume {
            changeTimerToState(.Resume)
            shouldResume = false
            shouldPause = true
            return
        }
        
        if shouldSuspend {
            shouldSuspend = false
            changeTimerToState(.Suspend)
        } else {
            shouldSuspend = true
            changeTimerToState(.Resume)
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
                }.onConclusion { status in
                    if status == .Finish {
                        self.viewController.timerDidFinish()
                    } else if status == .Reset {
                        self.viewController.setTimerLabelText("\(self.timer.startingTimeInMinutes!):00")
                    }
                }.activate()
        } else if state == .Cancel {
            timer.concludeWithStatus(.Reset)
        } else if state == .Pause || state == .Suspend {
            timer.concludeWithStatus(.Pause)
        }
        
        let timerStateToUpdateWorldWith = { () -> TimerButtonState? in
            switch state {
            case .Start:
                return .Suspend
            case .Resume:
                return .Suspend
            case .Pause:
                shouldResume = true
                return .Resume
            case .Cancel:
                return .Start
            case .Suspend:
                return nil // Maybe this is .Start?
            }
            
        }()
        
        if let timerStateToUpdateWorldWith = timerStateToUpdateWorldWith {
            viewController.setTimerButtonText(timerStateToUpdateWorldWith.rawValue)
        }
        
        if state == .Suspend {
            viewController.timerDidFinish()
        }
    }
    
    func userFinished() {
        // Do Nothing.
    }
}
