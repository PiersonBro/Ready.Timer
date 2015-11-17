//
//  ViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import QuartzCore
import Cartography
import Din
import TimerKit

protocol TimerViewControllerType {
    // FIXME: Change these to properties.
    func setTimerLabelText(text: String)
    func setTimerButtonText(text: String)
    func timerDidFinish()
}

class ViewController : UIViewController, TickerViewDataSource, TimerViewControllerType, UIGestureRecognizerDelegate {
    var tickerView: TickerView? = nil
    let timerLabel: UILabel
    let startButton: CircleButton
    let clockwiseButton: CircleButton
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer? = nil
    var engine: RoundUIEngine? = nil
    
    init(partialEngine: (viewController: TimerViewControllerType) -> RoundUIEngine) {
        timerLabel = UILabel(frame: CGRect())
        startButton = CircleButton(frame: CGRect())
        clockwiseButton = CircleButton(frame: CGRect())
    
        super.init(nibName: nil, bundle: nil)
        engine = partialEngine(viewController: self)
        tickerView = TickerView(frame: CGRect(), dataSource: self)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer!.delegate = self
        view.backgroundColor = .whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    //MARK: ViewController Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(doubleTapGestureRecognizer!)

        guard let tickerView = tickerView else { return }
        
        view.addSubview(tickerView)
        constrain(tickerView, view) { (tickerView, view) in
            tickerView.centerX == view.centerX
            tickerView.centerY == view.centerY * 2
            tickerView.width == view.width * 1 ~ 750
            tickerView.width == view.width * 0.8 ~ 500
            tickerView.height == tickerView.width
            tickerView.height <= view.height * 0.8
        }

        startButton.addTarget(self, action: "timerButtonPressed", forControlEvents: .TouchUpInside)
        startButton.labelText = "Start"
        view.addSubview(startButton)
        constrain(startButton, view, tickerView) { (startButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            startButton.centerX == view.centerX * 1.5
            startButton.centerY == tickerView.top - 100
            startButton.width == view.width * 0.2
            startButton.height == startButton.width
        }
        
        clockwiseButton.addTarget(self, action: "clockwise:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Clockwise"
        view.addSubview(clockwiseButton)
        constrain(clockwiseButton, view, tickerView) { (counterClockwiseButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            counterClockwiseButton.centerX == view.centerX * 0.4
            counterClockwiseButton.centerY == tickerView.top - 100

            counterClockwiseButton.width == view.width * 0.2
            counterClockwiseButton.height == counterClockwiseButton.width
        }
        
        timerLabel.font = UIFont.systemFontOfSize(160)
        view.addSubview(timerLabel)
        constrain(timerLabel, view) { (timerLabel, view) in
            timerLabel.centerX == view.centerX
            timerLabel.centerY == view.centerY / 2
        }
        tickerViewDidRotateStringAtIndexToCenterPosition(0)
    }
    
    func setTimerLabelText(text: String) {
        timerLabel.text = text
    }
    
    func setTimerButtonText(text: String) {
        //FIXME: Add proper localization support:
        startButton.labelText = text
    }

    //MARK: TimerButton
    func timerButtonPressed() {
        engine!.buttonTapped()
    }

    // MARK: Gesture Recognizers
    func tapped() {
        engine!.doubleTapped()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == view || touch.view == timerLabel {
            return true
        } else {
            return false
        }
    }
    
    //MARK: TickerView DataSource
    func stringForIndex(index: Int) -> String? {
        return engine!.displayNameForSegmentIndex(index)
    }
    
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int) {
        // We don't have to do anything. 
    }
        
    func tickerViewDidRotateToLastSpeech(index: Int) {
        // FIXME: What happens when the round ends?
    }
    
    // MARK: Next Speech
    func timerDidFinish() {
        #if !(arch(i386) || !arch(x86_64))
            let audioController = AudioController(type: Ringtone())
            let soundManager = audioController.playSound(.Ascending, repeating: true)
        #endif

        let action = UIAlertAction(title: "Done", style: .Default) { action in
            #if !(arch(i386) || !arch(x86_64))
                soundManager.stop()
            #endif
            self.startButton.labelText = "Start"
            self.engine!.userFinished()
            //FIXME: Should this be part of `userFinished`?
            self.engine!.next()
            self.tickerView!.rotateToNextSegment()
        }
        
        let actionController = UIAlertController(title: "Timer Done", message: nil, preferredStyle: .Alert)
        actionController.addAction(action)
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    //MARK: Debug
    //FIXME: THIS IS BROKEN!
    func clockwise(sender: CircleButton) {
        fatalError("Please burn this to the ground.")
    }
}
