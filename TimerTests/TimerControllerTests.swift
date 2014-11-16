//
//  TimerControllerTests.swift
//  Timer
//
//  Created by E&Z Pierson on 11/10/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Timer
import XCTest

class TimerControllerTests: XCTestCase {
    lazy var timerController: TimerController = {
        return TimerController(duration: 5)
    }()
    
    override func setUp() {
        
    }
    override func tearDown() {
        
    }
}
