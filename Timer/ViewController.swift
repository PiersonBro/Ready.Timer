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
    let timerLabel: UILabel
    let startButton: CircleButton
    let clockwiseButton: CircleButton
    
    var tickerView: TickerView? = nil
    var doubleTapGestureRecognizer: UITapGestureRecognizer? = nil
    var engine: RoundUIEngine? = nil
    
    init(partialEngine: (viewController: TimerViewControllerType) -> RoundUIEngine) {
        timerLabel = UILabel(frame: CGRect())
        startButton = CircleButton(frame: CGRect())
        clockwiseButton = CircleButton(frame: CGRect())
    
        super.init(nibName: nil, bundle: nil)
        engine = partialEngine(viewController: self)
        tickerView = TickerView(dataSource: self)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer!.delegate = self
        
        view.backgroundColor = engine?.configuration.backgroundColor
        view.tintColor = engine?.configuration.dominantTheme
        tickerView?.accentColor = engine!.configuration.accentColor
        startButton.accentColor = engine!.configuration.accentColor
        clockwiseButton.accentColor = engine!.configuration.accentColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    //MARK: ViewController Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(doubleTapGestureRecognizer!)
        view.tintColor = engine?.configuration.dominantTheme

        guard let tickerView = tickerView else { fatalError() }
        
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
        
        clockwiseButton.addTarget(self, action: "selectRound:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Select Round"
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
        //FIXME: Handle single string data sources.
        tickerViewDidRotateStringAtIndexToCenterPosition(0, wasDragged: false, wasLast: false)
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
        let result = engine!.displayNameForSegmentIndex(index)
        return result
    }

    var wasLast = false
    
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int, wasDragged: Bool, wasLast: Bool) {
        if wasDragged {
            engine!.userFinished()
            engine!.next()
            
            if self.wasLast {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tickerView?.reset()
                    self.wasLast = false
                }
            }
        }
        self.wasLast = wasLast
    }
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    let deviceIsSimulator = true
    #else
    let deviceIsSimulator = false
    #endif
    
    // MARK: Next Speech
    func timerDidFinish() {
        let soundManager: SoundManager?
        if deviceIsSimulator == false && engine?.configuration.ringerEnabled == true {
            let audioController = AudioController(type: Ringtone())
             soundManager = audioController.playSound(.Ascending, repeating: true)
        } else {
            soundManager = nil
        }

        let action = UIAlertAction(title: "Done", style: .Default) { action in
            if self.deviceIsSimulator == false {
                soundManager?.stop()
            }
            self.startButton.labelText = "Start"
            self.engine!.userFinished()
            //FIXME: Should this be part of `userFinished`?
            self.engine!.next()
            if self.wasLast {
                self.tickerView!.reset()
                self.wasLast = false
            } else {
                self.tickerView!.rotateToNextSegment()
            }
        }
        
        let actionController = UIAlertController(title: "Timer Done", message: nil, preferredStyle: .Alert)
        actionController.addAction(action)
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    func selectRound(sender: CircleButton) {
        let selectionViewController = SelectRoundViewController(rounds: Round.allRounds(), configuration: engine!.configuration)
        selectionViewController.modalPresentationStyle = .FormSheet
        presentViewController(selectionViewController, animated: true, completion: nil)
    }
}
