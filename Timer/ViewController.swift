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

class ViewController<Round: RoundType where Round.Segment == Speech> : UIViewController, TickerViewDataSource, UIGestureRecognizerDelegate {
    var tickerView: TickerView? = nil
    let timerLabel: UILabel
    let startButton: CircleButton
    let clockwiseButton: CircleButton
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer? = nil
    var debateRound: Round
    var currentSpeech: Round.Segment?
    
    init(round: Round) {
        timerLabel = UILabel(frame: CGRect())
        debateRound = round
        startButton = CircleButton(frame: CGRect())
        clockwiseButton = CircleButton(frame: CGRect())
    
        super.init(nibName: nil, bundle: nil)

        tickerView = TickerView(frame: CGRect(), dataSource: self)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer!.delegate = self
        self.view.backgroundColor = .whiteColor()
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
        layout(tickerView, view) { (tickerView, view) in
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
        layout(startButton, view, tickerView) { (startButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            startButton.centerX == view.centerX * 1.5
            startButton.centerY == tickerView.top - 100
            startButton.width == view.width * 0.2
            startButton.height == startButton.width
        }
        
        clockwiseButton.addTarget(self, action: "clockwise:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Clockwise"
        view.addSubview(clockwiseButton)
        layout(clockwiseButton, view, tickerView) { (counterClockwiseButton, view, tickerView) in
            // FIXME: Mispositioned Constraints
            counterClockwiseButton.centerX == view.centerX * 0.4
            counterClockwiseButton.centerY == tickerView.top - 100

            counterClockwiseButton.width == view.width * 0.2
            counterClockwiseButton.height == counterClockwiseButton.width
        }
        
        timerLabel.font = UIFont.systemFontOfSize(160)
        view.addSubview(timerLabel)
        layout(timerLabel, view) { (timerLabel, view) in
            timerLabel.centerX == view.centerX
            timerLabel.centerY == view.centerY / 2
        }
        tickerViewDidRotateStringAtIndexToCenterPosition(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TimerButton
    func timerButtonPressed() {
        //FIXME: This is confusing!
        changeTimerToState(.CurrentState)
    }
    
    private func changeTimerToState(state: TimerButtonState) {
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
                currentSpeech?.timer.onTick { elapsedTime in
                    self.timerLabel.text = String.formattedStringForDuration(elapsedTime)
                } .onConclusion { conclusionResult in
                    switch conclusionResult {
                        case .Overtime:
                            assert(self.currentSpeech!.timer.status.rawValue == "Overtime")
                            self.transitionToNextSpeech()
                        case .Reset:
                            self.timerLabel.text = "\(self.currentSpeech!.timer.startingTimeInMinutes!):00"
                        default:
                            break
                    }
                }.activate()
        } else if (startButton.labelText == "Cancel") {
                startButton.labelText = "Start"
                currentSpeech?.timer.concludeWithStatus(.Reset)
        } else if (startButton.labelText == "Pause") {
                startButton.labelText = "Resume"
                currentSpeech?.timer.concludeWithStatus(.Pause)
        }
    }
    
    // MARK: Gesture Recognizers
    
    func tapped() {
        if let currentSpeech = currentSpeech {
            switch(currentSpeech.timer.status) {
                case .Running:
                    changeTimerToState(.Pause)
                case .Paused:
                    changeTimerToState(.Resume)
                default:
                    break
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
        let transitionViewController = TransitionViewController(countUpTimer: debateRound.rightCountUpTimer!)
        self.presentViewController(transitionViewController, animated: true, completion: nil)
    }
    
    func rotateToNextSpeechIfPossible() {
        if let currentSpeech = currentSpeech {
            if currentSpeech.timer.status != .Running && currentSpeech.timer.status != .Paused {
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
    
    //MARK: TickerView DataSource
    func stringForIndex(index: Int) -> String? {
        if index >= debateRound.timers.count {
            // We are at the end of the Debate Round.
            return nil
        }
        let speech = debateRound.timers[index]
        return speech.name
    }
    
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int) {
        let speech = debateRound.timers[index]
        timerLabel.text = "\(speech.timer.startingTimeInMinutes!):00"
        currentSpeech = speech
    }
        
    func tickerViewDidRotateToLastSpeech(index: Int) {
        //FIXME: This needs to change before release.
//        debateRound = DebateRound(type: .LincolnDouglas)
    }
    
    // MARK: Next Speech
    func transitionToNextSpeech() {
        #if !(arch(i386) || !arch(x86_64))
            let audioController = AudioController(type: Ringtone())
            let soundManager = audioController.playSound(.Ascending, repeating: true)
        #endif

        let action = UIAlertAction(title: "Done", style: .Default) { action in
            #if !(arch(i386) || !arch(x86_64))
                soundManager.stop()
            #endif
            self.startButton.labelText = "Start"
            self.currentSpeech?.timer.concludeWithStatus(.Finish)
            self.tickerView!.rotateToNextSegment()
        }
        
        let actionController = UIAlertController(title: "Timer Done", message: nil, preferredStyle: .Alert)
        actionController.addAction(action)
        self.presentViewController(actionController, animated: true, completion: nil)
    }
}


private enum TimerButtonState: String {
    case Start = "Start"
    case Cancel = "Cancel"
    case Pause = "Pause"
    case Resume = "Resume"
    case CurrentState = ""
}


extension ViewController where Round.Segment.SegmentTimer == OvertimeTimer {
    
    func helloWorld(string: String) {
        print(Round.Segment.SegmentTimer.self)
    }
}
