//
//  CountUpTimerUIEngine.swift
//  Timer
//
//  Created by EandZ on 11/3/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

final class CountUpTimerUIEngine<T: SegmentType where T.SegmentTimer == SimpleTimer<CountUpBlueprint>>: TimerUIEngineType {
    typealias Segment = T
    typealias Configuration = DefaultConfiguration
    let segment: Segment
    let configuration = Configuration()
    let timer: Segment.SegmentTimer
    
    private let viewController: TimerViewControllerType
    private var state: TimerButtonState? = nil
    private var shouldSuspend = false
    private var shouldResume = false

    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        self.viewController = viewController
        timer = segment.generateTimer()
        viewController.setTimerLabelText(initialDisplayText)
    }
    
    func buttonTapped() {
        if shouldResume {
            changeTimerToState(.Resume)
            shouldResume = false
            shouldPause = true
            return
        }
        // If we've reached this point, it's backed by a `CountUpSegmentReference`.
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
    
    private func changeTimerToState(_ state: TimerButtonState) {
        if state == .Start || state == .Resume {
            timer.onTick { elapsedTime in
                self.viewController.setTimerLabelText(.formattedStringForDuration(elapsedTime))
                }.onConclusion { status in
                    if status == .Finish {
                        self.viewController.timerDidFinish()
                    } else if status == .Reset {
                        if let startingTimeInMinutes = self.timer.startingTimeInMinutes {
                            self.viewController.setTimerLabelText("\(startingTimeInMinutes):00")
                        } else if let startingTimeInSeconds = self.timer.startingTimeInSeconds {
                            self.viewController.setTimerLabelText(.formattedStringForDuration(startingTimeInSeconds))
                        } else {
                            fatalError("Both startingTimeInMinutes and startingTimeInSeconds cannot be nil")
                        }
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
