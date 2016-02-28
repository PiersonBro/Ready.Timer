//
//  InfiniteTimerUIEngine.swift
//  Timer
//
//  Created by EandZ on 11/3/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

final class InfiniteTimerUIEngine<T: SegmentType where T.SegmentTimer == Timer<InfiniteBlueprint>>: TimerUIEngineType {
    typealias Segment = T
    typealias Configuration = InfiniteUIConfiguration
    
    let segment: T
    let configuration = Configuration()
    let timer: T.SegmentTimer
    private let viewController: TimerViewControllerType
    
    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        timer = segment.generateTimer()
        self.viewController = viewController
        viewController.setTimerLabelText(initialDisplayText)
    }
    
    func buttonTapped() {
        if timer.status == .Inactive || timer.status == .Paused {
            changeTimerToState(.Start)
        } else if timer.status == .Running {
            timer.concludeWithStatus(.Finish)
        }

    }
    
    //FIXME: Consider making this a protocol extension.
    var shouldPause = true
    func doubleTapped() {
        if shouldPause {
            changeTimerToState(.Pause)
            shouldPause = false
        } else {
            changeTimerToState(.Resume)
            shouldPause = true
        }
    }
    
    func userFinished() {
        if timer.status != .Finished {
            timer.concludeWithStatus(.Finish)
        }
    }
    
    private func changeTimerToState(state: TimerButtonState) {
        if state == .Start || state == .Resume {
            timer.onTick { elapsedTime in
                self.viewController.setTimerLabelText(.formattedStringForDuration(elapsedTime))
                }.onConclusion { conclusionStatus in
                    switch conclusionStatus {
                    case .Finish:
                        self.viewController.timerDidFinish()
                    default:
                        break
                    }
            }.activate()
        } else if state == .Pause {
            timer.concludeWithStatus(.Pause)
        }
        
        let labelText: String?
        switch state {
            case .Start:
                labelText = "Finish"
            case .Pause:
                labelText = "Resume"
            case .Resume:
                labelText = "Finish"
            default:
                labelText = nil
        }
       
        if let labelText = labelText {
            viewController.setTimerButtonText(labelText)
        }
    }
}
