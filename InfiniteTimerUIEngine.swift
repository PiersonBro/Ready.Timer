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
    typealias Configuration = DefaultConfiguration
    
    let segment: T
    let configuration = Configuration()
    private let timer: T.SegmentTimer
    private let viewController: TimerViewControllerType
    
    init(segment: Segment, viewController: TimerViewControllerType) {
        self.segment = segment
        timer = segment.timer
        self.viewController = viewController
        viewController.setTimerLabelText(initialDisplayText)
    }
    
    func buttonTapped() {
        
    }
    
    //FIXME: Consider making this a protocol extension.
    var shouldPause = true
    func doubleTapped() {
        if shouldPause {
            changeTimerToState(.Pause)
            shouldPause = false
        } else {
            changeTimerToState(.Start)
            shouldPause = true
        }
    }
    
    func userFinished() {
        timer.concludeWithStatus(.Finish)
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
            }
        } else if state == .Pause {
            timer.concludeWithStatus(.Pause)
        }
    }
}
