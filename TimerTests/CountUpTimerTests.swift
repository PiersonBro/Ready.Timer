//
//  CountUpTimerTests.swift
//  Timer
//
//  Created by E&Z Pierson on 1/15/15.
//  Copyright (c) 2015 E&Z Pierson. All rights reserved.
//

import Timer
import XCTest

class CountUpTimerTests: XCTestCase {
    var countUpTimerController: TimerController<CountUpTimer>!
    
    override func setUp() {
        super.setUp()
        countUpTimerController = TimerController(timer: CountUpTimer(upperLimitInMinutes: (5 / 60)))
    }
    
    override func tearDown() {
        countUpTimerController = nil
        super.tearDown()
    }

    func testCountUpTimer() {
        measureMetrics(XCTestCase.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) {
            let expectedResults = ["0:01", "0:02", "0:03", "0:04", "0:05"]
            var actualResults = Array<String>()
            
            let expectation = self.expectationWithDescription("It Should Wait till the timer is over")
            self.startMeasuring()
            
            self.countUpTimerController.activateWithBlock({ elapsedTime in
                actualResults.append(elapsedTime)
                if elapsedTime == "0:00" {
                    self.stopMeasuring()
                }
            }, conclusionBlock: { conclusionResult in
                expectation.fulfill()
                for var i = 0; i < expectedResults.count; ++i {
                    XCTAssert(expectedResults[i] == actualResults[i], "Expected \(expectedResults[i]) got \(actualResults[i])")
                }
            })
            
            self.waitForExpectationsWithTimeout(10, handler: nil)
        }
    }

}
