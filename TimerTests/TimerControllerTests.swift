//
//  TimerControllerTests.swift
//  Timer
//
//  Created by E&Z Pierson on 11/10/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Timer
import XCTest

class TimerControllerTests : XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testCountUpTimerStatus() {
        let duration: NSTimeInterval = (5 / 60)
        
        let statusTests = StatusTests(testCase: self) {
            CountUpTimer(upperLimitInMinutes: duration)
        }
        statusTests.start()
    }
    
    func testCountDownTimerStatus() {
        let duration: NSTimeInterval = (5 / 60)
        
        let statusTests = StatusTests(testCase: self) {
            CountDownTimer(durationInMinutes: duration)
        }
        statusTests.start()
    }
}

class StatusTests<T: TimerType> {
    var timerController: TimerController<T>
    let timerGenerator: (Void -> T)
    let testCase: XCTestCase
    
    init(testCase: XCTestCase, timerGenerator: (Void -> T)) {
        self.timerGenerator = timerGenerator
        self.timerController = TimerController(timer: timerGenerator())
        self.testCase = testCase
    }
    
    func start() {
        testInactiveState()
        timerController = TimerController(timer: timerGenerator())

        testRunningState()
        timerController = TimerController(timer: timerGenerator())
        
        testFinishedState()
        timerController = TimerController(timer: timerGenerator())
        
        testPausedState()
        timerController = TimerController(timer: timerGenerator())
        
        testResetState()
        timerController = TimerController(timer: timerGenerator())

        testRepetedPauseToggling()
    }
    
    //MARK: Status
    func testInactiveState() {
        XCTAssert(timerController.status == .Inactive, "The timer should be inactive when the timer hasn't started")
    }
    
    func testRunningState() {
        timerController.activateWithBlock({ (elapsedTime) in
            }, conclusionBlock: { (conclusionStatus) in
                
        })
        XCTAssert(timerController.status == .Running, "The timer should be running when the timer has started")
    }
    
    func testFinishedState() {
        let expectation = testCase.expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ elapsedTime in
            XCTAssert(self.timerController.status == .Running, "Status should be .Running every time this block is executed")
            }, conclusionBlock: { conclusionResult in
                expectation.fulfill()
                XCTAssert(conclusionResult.conclusionStatus == .Finished, "It should be finished when it is finished")
                XCTAssert(self.timerController.status == .Finished, "It Should be finished when the timer is finished")
        })
        
        testCase.waitForExpectationsWithTimeout(480, handler: nil)
    }
    
    func testPausedState() {
        let expectation = testCase.expectationWithDescription("The timer should have fired it's blocks")
        timerController.activateWithBlock({ (elapsedTime) in
            let number = self.convertElapsedTimeToNumber(elapsedTime)
            if number <= 3 {
                self.timerController.concludeWithStatus(.Paused)
            }
        }, conclusionBlock: { conclusionResult in
                    XCTAssert(conclusionResult.conclusionStatus == .Paused, "It Should be paused after it was paused")
                    XCTAssert(self.timerController.status == .Paused, "It should be paused after it was paused")
            self.timerController.activateWithBlock({ (elapsedTime) -> () in
                let number = self.convertElapsedTimeToNumber(elapsedTime)
                if number != 2 && number != 3 {
                    XCTFail("Pause isn't working")
                } else {
                    self.timerController.concludeWithStatus(.Paused)
                }
            }) { conclusionResult in
                expectation.fulfill()
            }
        })
        
        testCase.waitForExpectationsWithTimeout(120, handler:nil)
    }
    
    func testResetState() {
        let expectation = testCase.expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            self.timerController.concludeWithStatus(.Reset)
            }, conclusionBlock: { conclusionResult in
                expectation.fulfill()
                
                XCTAssert(conclusionResult.conclusionStatus == .Reset, "The conclusionStatus should be `.Reset` after it was Reset")
                XCTAssert(self.timerController.status == .Inactive, "The timer should now be inactive")
        })
        
        testCase.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRepetedPauseToggling() {
        let expectation = testCase.expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            XCTAssert(self.timerController.status == .Running, "The timer should be running now")
            self.timerController.concludeWithStatus(.Paused)
            
            }, conclusionBlock: { conclusionResult in
                XCTAssert(conclusionResult.conclusionStatus == .Paused, "It Should be paused after it was paused")
                XCTAssert(self.timerController.status == .Paused, "It should be paused after it was paused")
                
                self.timerController.activateWithBlock({ elapsedTime in
                    XCTAssert(self.timerController.status == .Running, "It should be running again")
                    self.timerController.concludeWithStatus(.Paused)
                    
                    }, conclusionBlock: { conclusionResult in
                        XCTAssert(conclusionResult.conclusionStatus == .Paused, "It should be paused")
                        XCTAssert(self.timerController.status == .Paused, "The timer.status should be paused")
                        expectation.fulfill()
                })
        })
        
        testCase.waitForExpectationsWithTimeout(120, handler:nil)
    }
        
    private func convertElapsedTimeToNumber(elapsedTime: String) -> Int {
        let numberCharacter = elapsedTime[elapsedTime.endIndex.predecessor()]
        let intermediaryString = String(numberCharacter)
        return intermediaryString.toInt()!

    }
}
