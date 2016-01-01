//
//  CountDownTimerUIEngine.swift
//  Timer
//
//  Created by EandZ on 11/3/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

final class CountDownTimerUIEngine: TimerUIEngineType {
    typealias Segment = CountDownSegment
    typealias Configuration = DefaultConfiguration
    let segment: Segment
    let configuration = Configuration()
    let timer: Segment.SegmentTimer
    
    private let viewController: TimerViewControllerType
    private var state: TimerButtonState? = nil
    
    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        self.viewController = viewController
        timer = segment.generateTimer()
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
                }.onConclusion { status in
                    if status == .Finish {
                        self.viewController.timerDidFinish()
                    } else if status == .Reset {
                        self.viewController.setTimerLabelText("\(self.timer.startingTimeInMinutes!):00")
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
        // Do Nothing.
    }
}
