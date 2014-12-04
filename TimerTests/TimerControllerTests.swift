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
    var timerController: TimerController!
    override func setUp() {
        super.setUp()
        let duration: Double = (5 / 60)
        timerController = TimerController(durationInMinutes: duration)
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
        let strings = ["0:05", "0:04", "0:03", "0:02", "0:01","0:00"]
        var index = 0
        
        timerController.activateWithBlock({ elapsedTime in
            let string = strings[index]
            XCTAssert(string == elapsedTime, "Elapsed time should be \(strings[index]) was \(elapsedTime)")
            XCTAssert(self.timerController.status == .Running, "It should be running every time this block is executed")
            index++
            }, conclusionBlock: { conclusionStatus in
                expectation.fulfill()
                XCTAssert(conclusionStatus == .Finished, "It should be finished when it is finished")
                XCTAssert(self.timerController.status == .Finished, "It Should be finished when the timer is finished")
        })
        
        waitForExpectationsWithTimeout(480, handler: nil)
    }

    func testPausedState() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            self.timerController.concludeWithStatus(.Paused)
        }, conclusionBlock: { (conclusionStatus) in
            expectation.fulfill()
            XCTAssert(conclusionStatus == .Paused, "It Should be paused after it was paused")
            XCTAssert(self.timerController.status == .Paused, "It should be paused after it was paused")
        })
        
        waitForExpectationsWithTimeout(5, handler:nil)
    }
    
    func testResetState() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")
        
        timerController.activateWithBlock({ (elapsedTime) in
            self.timerController.concludeWithStatus(.Reset)
            }, conclusionBlock: { (conclusionStatus) in
                expectation.fulfill()
                XCTAssert(conclusionStatus == .Reset, "The conclusionStatus should be `.Reset` after it was Reset")
                XCTAssert(self.timerController.status == .Inactive, "The timer should now be inactive")
        })
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testRepetedPauseToggling() {
        let expectation = expectationWithDescription("The timer should have fired it's blocks")

        timerController.activateWithBlock({ (elapsedTime) in
            XCTAssert(self.timerController.status == .Running, "The timer should be running now")
            self.timerController.concludeWithStatus(.Paused)
            }, conclusionBlock: { (conclusionStatus) in
                XCTAssert(conclusionStatus == .Paused, "It Should be paused after it was paused")
                XCTAssert(self.timerController.status == .Paused, "It should be paused after it was paused")
                
                self.timerController.activateWithBlock({ elapsedTime in
                    XCTAssert(self.timerController.status == .Running, "It should be running again")
                    self.timerController.concludeWithStatus(.Paused)
                }, conclusionBlock: { conclusionStatus in
                    XCTAssert(conclusionStatus == .Paused, "It should be paused")
                    XCTAssert(self.timerController.status == .Paused, "The timer.status should be paused")
                    expectation.fulfill()
                })
        })
        
        waitForExpectationsWithTimeout(5, handler:nil)
    }

    override func tearDown() {
        super.tearDown()
        timerController = nil
    }
}
