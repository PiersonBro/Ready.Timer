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
    var timerController: TimerController<CountDownTimer>!
    override func setUp() {
        super.setUp()
        let duration: NSTimeInterval = (5 / 60)
        let countDownTimer = CountDownTimer(durationInMinutes: duration)
        timerController = Controller(controllerDataSource:countDownTimer)
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
        let expectation = expectationWithDescription("The timer should have fired it's blocks")
        let strings = ["0:04", "0:03", "0:02", "0:01","0:00"]
        var index = 0
        
        timerController.activateWithBlock({ elapsedTime in
            let string = strings[index]
            XCTAssert(string == elapsedTime, "Elapsed time should be \(strings[index]) was \(elapsedTime)")
            XCTAssert(self.timerController.status == .Running, "It should be running every time this block is executed")
            index++
            }, conclusionBlock: { (conclusionResult) in
                expectation.fulfill()
                XCTAssert(conclusionResult.conclusionStatus == .Finished, "It should be finished when it is finished")
                XCTAssert(self.timerController.status == .Finished, "It Should be finished when the timer is finished")
        })
        
        waitForExpectationsWithTimeout(480, handler: nil)
    }

    func testPausedState() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            self.timerController.concludeWithStatus(.Paused)
        }, conclusionBlock: { conclusionResult in
            expectation.fulfill()
            
            XCTAssert(conclusionResult.conclusionStatus == .Paused, "It Should be paused after it was paused")
            XCTAssert(self.timerController.status == .Paused, "It should be paused after it was paused")
        })
        
        waitForExpectationsWithTimeout(5, handler:nil)
    }
    
    func testResetState() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            self.timerController.concludeWithStatus(.Reset)
            }, conclusionBlock: { conclusionResult in
                expectation.fulfill()
                
                XCTAssert(conclusionResult.conclusionStatus == .Reset, "The conclusionStatus should be `.Reset` after it was Reset")
                XCTAssert(self.timerController.status == .Inactive, "The timer should now be inactive")
        })
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRepetedPauseToggling() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")

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
        
        waitForExpectationsWithTimeout(5, handler:nil)
    }
    
    func testResetToPausedState() {
        timerController.activateWithBlock({ elapsedTime in
            if elapsedTime == "0:02" {
                self.timerController.concludeWithStatus(.Paused)
            }
        }) { conclusionResult in
            self.timerController.activateWithBlock({ elapsedTime in
                if elapsedTime == "0:04" {
                    self.timerController.concludeWithStatus(.ResetToPaused)
                }
            }) { conclusionResult in
                XCTAssert(self.timerController.timer.duration == 2, "The timer's duration should be 2")
            }
        }
    }

    override func tearDown() {
        super.tearDown()
        timerController = nil
    }
}
