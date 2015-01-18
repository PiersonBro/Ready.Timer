//
//  CountDownTimerTests.swift
//  Timer
//
//  Created by E&Z Pierson on 1/14/15.
//  Copyright (c) 2015 E&Z Pierson. All rights reserved.
//

import Timer
import XCTest

class CountDownTimerTests: XCTestCase {
    var countDownTimerController: TimerController<CountDownTimer>!
    
    override func setUp() {
        countDownTimerController = TimerController(timer: CountDownTimer(durationInMinutes: (5 / 60)))
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testTimerString() {
        measureMetrics(XCTestCase.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) {
            let expectation = self.expectationWithDescription("Timer Expectation")
            let expectedResults = ["0:04", "0:03", "0:02", "0:01","0:00"]
            var actualResults = Array<String>()
            
            self.startMeasuring()
            self.countDownTimerController.activateWithBlock({ elapsedTime in
                actualResults.append(elapsedTime)
                if elapsedTime == "0:00" {
                    self.stopMeasuring()
                }
            }, conclusionBlock: { conclusionResult in
                expectation.fulfill()
                for var i = 0; i < expectedResults.count; ++i {
                    let expectedString = expectedResults[i]
                    let actualString = actualResults[i]
                    XCTAssert(expectedString == actualString, "Expected \(expectedString) got \(actualString)")
                }
            })
        
            self.waitForExpectationsWithTimeout(10, handler: nil)
        }
    }

}
