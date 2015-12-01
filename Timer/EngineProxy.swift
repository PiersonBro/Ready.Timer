//
//  EngineProxy.swift
//  Timer
//
//  Created by EandZ on 10/29/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation

// This erases TimerUIEngineType Assocaited Types.
struct EngineProxy /* TimerUIEngineType */ {
    typealias Engines = (OvertimeUIEngine<OvertimeSegment>?, InfiniteTimerUIEngine<InfiniteSegment>?, CountUpTimerUIEngine?, CountDownTimerUIEngine?)
    let engines: Engines
    var configuration: UIConfigurationType {
        if let overtimeUIEngine = engines.0 {
            return overtimeUIEngine.configuration
        } else if let infiniteTimerUIEngine = engines.1 {
            return infiniteTimerUIEngine.configuration
        } else if let countUpUIEngine = engines.2 {
            return countUpUIEngine.configuration
        } else if let countDownEngine = engines.3 {
            return countDownEngine.configuration
        } else {
            fatalError("Exhaustive list is not exhaustive")
        }
    }
    
    init(engines: Engines) {
        self.engines = engines
    }
    
    func buttonTapped() {
        if let overtimeUIEngine = engines.0 {
            overtimeUIEngine.buttonTapped()
        } else if let infiniteTimerUIEngine = engines.1 {
            infiniteTimerUIEngine.buttonTapped()
        } else if let countUpUIEngine = engines.2 {
            countUpUIEngine.buttonTapped()
        } else if let countDownEngine = engines.3 {
            countDownEngine.buttonTapped()
        }
    }
    
    func doubleTapped() {
        if let overtimeUIEngine = engines.0 {
            overtimeUIEngine.doubleTapped()
        } else if let infiniteTimerUIEngine = engines.1 {
            infiniteTimerUIEngine.doubleTapped()
        } else if let countUpUIEngine = engines.2 {
            countUpUIEngine.doubleTapped()
        } else if let countDownEngine = engines.3 {
            countDownEngine.doubleTapped()
        }
    }
    
    func userFinished() {
        if let overtimeUIEngine = engines.0 {
            overtimeUIEngine.userFinished()
        } else if let infiniteTimerUIEngine = engines.1 {
            infiniteTimerUIEngine.userFinished()
        } else if let countUpUIEngine = engines.2 {
            countUpUIEngine.userFinished()
        } else if let countDownEngine = engines.3 {
            countDownEngine.userFinished()
        }
    }
    
    static func engineForSegment(segmentProxy: SegmentProxy, viewController: TimerViewControllerType) -> EngineProxy {
        let segments = segmentProxy.segments
        let overtimeSegment = segments.0
        let infiniteSegment = segments.1
        let countUpSegment = segments.2
        let countDownSegment = segments.3
        
        if let overtimeSegment = overtimeSegment {
            let overtimeUIEngine: OvertimeUIEngine<OvertimeSegment> = OvertimeUIEngine(segment: overtimeSegment, viewController: viewController)
            return EngineProxy(engines: (overtimeUIEngine, nil, nil, nil))
        } else if let infiniteSegment = infiniteSegment {
            let infiniteUIEngine = InfiniteTimerUIEngine(segment: infiniteSegment, viewController: viewController)
            return EngineProxy(engines: (nil, infiniteUIEngine, nil, nil))
        } else if let countUpSegment = countUpSegment {
            let countUpUIEngine = CountUpTimerUIEngine(segment: countUpSegment, viewController: viewController)
            return EngineProxy(engines: (nil, nil, countUpUIEngine, nil))
        } else if let countDownSegment = countDownSegment {
            let countDownUIEngine = CountDownTimerUIEngine(segment: countDownSegment, viewController: viewController)
            return EngineProxy(engines: (nil, nil, nil, countDownUIEngine))
        } else {
            fatalError("Failed To Create Engine Proxy")
        }
    }
}

