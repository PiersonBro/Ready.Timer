//
//  EngineProxy.swift
//  Timer
//
//  Created by EandZ on 10/29/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation

// This erases TimerUIEngineType Associated Types.
struct EngineProxy /* TimerUIEngineType */ {
    typealias Engines = (OvertimeUIEngine<OvertimeSegment>?, InfiniteTimerUIEngine<InfiniteSegment>?, CountUpTimerUIEngine<CountUpSegment>?, CountDownTimerUIEngine?, CountUpTimerUIEngine<CountUpSegmentReference>?)
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
        } else if let countUpReferenceEngine = engines.4 {
            return countUpReferenceEngine.configuration
        } else {
            fatalError("EngineProxy.configuration is incompletely implemented")
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
        } else if let countUpReferenceEngine = engines.4 {
            countUpReferenceEngine.buttonTapped()
        } else {
            fatalError("EngineProxy.buttonTapped() is incompletely implemented")
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
        } else if let countUpReferenceEngine = engines.4 {
            countUpReferenceEngine.doubleTapped()
        } else {
            fatalError("EngineProxy.doubleTapped() is incompletely implemented")
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
    
    static func engineForSegment(_ segmentProxy: SegmentProxy, viewController: TimerViewControllerType) -> EngineProxy {
        let segments = segmentProxy.segments
        let overtimeSegment = segments.0
        let infiniteSegment = segments.1
        let countUpSegment = segments.2
        let countDownSegment = segments.3
        let countUpReference = segments.4
        
        if let overtimeSegment = overtimeSegment {
            let overtimeUIEngine: OvertimeUIEngine<OvertimeSegment> = OvertimeUIEngine(segment: overtimeSegment, viewController: viewController)
            return EngineProxy(engines: (overtimeUIEngine, nil, nil, nil, nil))
        } else if let infiniteSegment = infiniteSegment {
            let infiniteUIEngine = InfiniteTimerUIEngine(segment: infiniteSegment, viewController: viewController)
            return EngineProxy(engines: (nil, infiniteUIEngine, nil, nil, nil))
        } else if let countUpSegment = countUpSegment {
            let countUpUIEngine = CountUpTimerUIEngine(segment: countUpSegment, viewController: viewController)
            return EngineProxy(engines: (nil, nil, countUpUIEngine, nil, nil))
        } else if let countDownSegment = countDownSegment {
            let countDownUIEngine = CountDownTimerUIEngine(segment: countDownSegment, viewController: viewController)
            return EngineProxy(engines: (nil, nil, nil, countDownUIEngine, nil))
        } else if let countUpReference = countUpReference {
            let countDownReferenceUIEngine = CountUpTimerUIEngine(segment: countUpReference, viewController: viewController)
            return EngineProxy(engines: (nil,nil, nil, nil, countDownReferenceUIEngine))
        } else {
            fatalError("Failed To Create Engine Proxy")
        }
    }
}

