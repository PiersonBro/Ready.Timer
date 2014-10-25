//
//  ViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

class ViewController: UIViewController, TickerViewDataSource, TickerViewDelegate {
    let tickerView: TickerView?
    let timerLabel: UILabel
    let debateRoundManager: DebateRoundManager?
    var tickerViewIsOnLastSpeech: Bool
 
    let clockwiseButton: CircleButton
    let counterClockwiseButton: CircleButton
    
    required init(coder aDecoder: NSCoder) {
        timerLabel = UILabel(frame: CGRect())
        debateRoundManager = DebateRoundManager(type: .TeamPolicy)
        tickerViewIsOnLastSpeech = false
        clockwiseButton = CircleButton(frame: CGRect())
        counterClockwiseButton = CircleButton(frame: CGRect())
      
        super.init(coder: aDecoder)
        tickerView = TickerView(frame: CGRect(), dataSource: self, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        clockwiseButton.addTarget(self, action: "clockwise:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Clockwise"
        clockwiseButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(clockwiseButton)
        layout(clockwiseButton, view, tickerView!) { (clockwiseButton, view, tickerView) in
            // FIXME: Mispoisitioned Constraints
            clockwiseButton.centerX == view.centerX * 1.5
            clockwiseButton.centerY == tickerView.top - 100
            
            clockwiseButton.width == view.width * 0.2
            clockwiseButton.height == clockwiseButton.width
        }
        
        counterClockwiseButton.addTarget(self, action: "counterClockwise:", forControlEvents: .TouchUpInside)
        counterClockwiseButton.labelText = "Counterclockwise"
        counterClockwiseButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(counterClockwiseButton)
        layout(counterClockwiseButton, view, tickerView!) { (counterClockwiseButton, view, tickerView) in
            // FIXME: Mispoisitioned Constraints
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

    func clockwise(sender: AnyObject) {
        tickerView!.rotateToNextSegment()
    }
    
    func counterClockwise(sender: AnyObject) {
        tickerView!.rotateToPreviousSegment()
    }
    
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
    }
    
    func stringShouldBeChanged(index: Int) -> Bool {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        if (speech.consumed) {
            return true
        }
        
        return false
    }
    
    func tickerViewDidRotateToLastSpeech(index: Int) {
        tickerViewIsOnLastSpeech = true
    }
}
