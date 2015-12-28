//
//  RoundUIEngine.swift
//  Timer
//
//  Created by EandZ on 10/20/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

protocol RoundUIEngineType {
    var configuration: UIConfigurationType { get }
    var segment: SegmentProxy { get }
    static func createEngine(round: Round) -> (viewController: TimerViewControllerType) -> Self
    // UI Interaction
    func buttonTapped()
    func doubleTapped()
    func userFinished()
    // Moves the currentTimer up one.
    func next()
}

final class RoundUIEngine: RoundUIEngineType {
    var configuration: UIConfigurationType {
        return engine.configuration
    }
    
    private let round: Round

    private let viewController: TimerViewControllerType
    
    private var engine: EngineProxy
    private var mutableSegmentProxies: [SegmentProxy?]
    private(set) var segment: SegmentProxy

    static func createEngine(round: Round) -> (viewController: TimerViewControllerType) -> RoundUIEngine {
        let block: (viewController: TimerViewControllerType) -> RoundUIEngine = { viewController in
            RoundUIEngine(round: round, viewController: viewController)
        }
        return block
    }
    
    init(round: Round, viewController: TimerViewControllerType) {
        self.round = round
        self.viewController = viewController
        mutableSegmentProxies = round.segmentProxies
        segment = mutableSegmentProxies.removeFirst()!
        engine = .engineForSegment(segment, viewController: viewController)
    }
    
    // MARK: UI Interaction
    func buttonTapped() {
        engine.buttonTapped()
    }
    
    func doubleTapped() {
        engine.doubleTapped()
    }
    
    func userFinished() {
        engine.userFinished()
    }
    
    func next() {
        if let partiallyUnwrappedSegment = mutableSegmentProxies.first {
            if let normalSegment = partiallyUnwrappedSegment {
                segment = normalSegment
                mutableSegmentProxies.removeFirst()
            }
        } else {
            // FIXME: We just start over here instead of shelling out to the view controller.
            mutableSegmentProxies = round.segmentProxies
            segment = mutableSegmentProxies.removeFirst()!
        }
        engine = .engineForSegment(segment, viewController: viewController)
    }
    
    func displayNameForSegmentIndex(index: Int) -> String? {
        if index >= round.segmentProxies.count {
            return nil
        }
        
        return round.segmentProxies[index]!.name
    }
}
