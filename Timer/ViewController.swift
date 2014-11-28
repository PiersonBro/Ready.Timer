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

class ViewController: UIViewController, TickerViewDataSource, TickerViewDelegate, UIGestureRecognizerDelegate {
    let tickerView: TickerView?
    let timerLabel: UILabel
    let debateRoundManager: DebateRoundManager?
    var currentSpeech: Speech?
    let doubleTapGestureRecognizer: UITapGestureRecognizer
    let startButton: CircleButton
    let clockwiseButton: CircleButton
    
    required init(coder aDecoder: NSCoder) {
        timerLabel = UILabel(frame: CGRect())
        debateRoundManager = DebateRoundManager(type: .TeamPolicy)
        startButton = CircleButton(frame: CGRect())
        clockwiseButton = CircleButton(frame: CGRect())
        doubleTapGestureRecognizer = UITapGestureRecognizer()
        super.init(coder: aDecoder)
        tickerView = TickerView(frame: CGRect(), dataSource: self, delegate: self)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
    }
    
    //MARK: ViewController Lifecycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(doubleTapGestureRecognizer)

        tickerView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tickerView!)
       
        layout(tickerView!, view) { (tickerView, view) in
            tickerView.centerX == view.centerX
            tickerView.centerY == view.centerY * 2
            tickerView.width == view.width * 1 ~ 750
            tickerView.width == view.width * 0.8 ~ 500
            tickerView.height == tickerView.width
            tickerView.height <= view.height * 0.8
        }

        startButton.addTarget(self, action: "timerButtonPressed", forControlEvents: .TouchUpInside)
        startButton.labelText = "Start"
        startButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(startButton)
        layout(startButton, view, tickerView!) { (startButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            startButton.centerX == view.centerX * 1.5
            startButton.centerY == tickerView.top - 100
            startButton.width == view.width * 0.2
            startButton.height == startButton.width
        }
        
        clockwiseButton.addTarget(self, action: "clockwise:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Clockwise"
        clockwiseButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(clockwiseButton)
        layout(clockwiseButton, view, tickerView!) { (counterClockwiseButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            counterClockwiseButton.centerX == view.centerX * 0.4
            counterClockwiseButton.centerY == tickerView.top - 100

            counterClockwiseButton.width == view.width * 0.2
            counterClockwiseButton.height == counterClockwiseButton.width
        }
        
        timerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        timerLabel.font = UIFont.systemFontOfSize(160)
        view.addSubview(timerLabel)
        layout(timerLabel, view) { (timerLabel, view) in
            timerLabel.centerX == view.centerX
            timerLabel.centerY == view.centerY / 2
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TimerButton

    func timerButtonPressed() {
        changeTimerToState(.CurrentState)
    }
    
    enum TimerButtonState: String {
        case Start = "Start"
        case Cancel = "Cancel"
        case Pause = "Pause"
        case Resume = "Resume"
        case CurrentState = ""
    }
    
    func changeTimerToState(state: TimerButtonState) {
        switch state {
            case .Start:
                startButton.labelText = TimerButtonState.Start.rawValue
            case .Cancel:
                startButton.labelText = TimerButtonState.Cancel.rawValue
            case .Pause:
                startButton.labelText = TimerButtonState.Pause.rawValue
            case .Resume:
                startButton.labelText = TimerButtonState.Resume.rawValue
            case .CurrentState:
                break
        }
        
        if (startButton.labelText == "Start" || startButton.labelText == "Resume") {
                startButton.labelText = "Cancel"
                currentSpeech?.timerController.activateWithBlock({ (elapsedTime) in
                    self.timerLabel.text = elapsedTime
                }, conclusionBlock: { (completionStatus) in
                    switch completionStatus {
                        case .Finished:
                            // Calling this will also mark the speech as consumed, yay side effects.
                            self.tickerView?.rotateToNextSegment()
                            self.startButton.labelText = "Start"
                        case .Reset:
                            self.timerLabel.text = "\(self.currentSpeech!.speechType.durationOfSpeech()):00"
                        case .Paused:
                            break
                        }
                })
        } else if (startButton.labelText == "Cancel") {
                startButton.labelText = "Start"
                currentSpeech?.timerController.concludeWithStatus(.Reset)
        } else if (startButton.labelText == "Pause") {
                startButton.labelText = "Resume"
                currentSpeech?.timerController.concludeWithStatus(.Paused)
        }
    }
    
    // MARK: Gesture Recognizers
    
    func tapped() {
        if let currentSpeech = currentSpeech {
            if currentSpeech.timerController.status == .Running {
                changeTimerToState(.Pause)
            } else if currentSpeech.timerController.status == .Paused {
                changeTimerToState(.Resume)
            } else {
                return
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == view || touch.view == timerLabel {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Debug
    func clockwise(sender: CircleButton) {
        if let currentSpeech = currentSpeech {
            if currentSpeech.timerController.status != .Running && currentSpeech.timerController.status != .Paused {
                tickerView!.rotateToNextSegment()
            } else {
                // FIXME: Add a better denied animation here.
                let animation = CAKeyframeAnimation(keyPath: "transform")
                let initialValue = NSValue(CATransform3D: CATransform3DMakeTranslation(-6.0, 0.0, 0.0))
                let finalValue = NSValue(CATransform3D: CATransform3DMakeTranslation(6.0, 0.0, 0.0))
                animation.values = [initialValue, finalValue]
                animation.autoreverses = true
                animation.duration = 0.5
                animation.repeatCount = 2.0
                clockwiseButton.layer.addAnimation(animation, forKey:nil)
            }
        } else {
            tickerView!.rotateToNextSegment()
        }
    }
    
    //MARK: TickerView DataSource and Delegate
    func stringForIndex(index: Int) -> String? {
        if index >= debateRoundManager!.speechCount {
            // We are at the end of the Debate Round.
            return nil
        }
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        return speech.name
    }
    
    func tickerViewDidRotateStringAtIndexToRightPosition(index: Int) {
        debateRoundManager?.markSpeechAsConsumedAtIndex(index)
    }
    
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int) {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        timerLabel.text = "\(speech.speechType.durationOfSpeech()):00"
        currentSpeech = speech
    }
    
    func stringShouldBeChanged(index: Int) -> Bool {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        if (speech.consumed) {
            return true
        }
        
        return false
    }
    
    func tickerViewDidRotateToLastSpeech(index: Int) {
    }
}
