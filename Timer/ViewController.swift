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
        let xConstraint = NSLayoutConstraint(item: tickerView!, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: tickerView!, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 2, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: tickerView!, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: tickerView!, attribute: .Height, relatedBy: .Equal, toItem: tickerView, attribute: .Width, multiplier: 1, constant: 0)
        view.addSubview(tickerView!)
        NSLayoutConstraint.activateConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])

        timerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        timerLabel.font = UIFont.systemFontOfSize(160)
        view.addSubview(timerLabel)
        let labelConstraints = NSLayoutConstraint.generateConstraints(timerLabel, toItem: view, xMultiplier: 1, yMultiplier: 0.5)
        NSLayoutConstraint.activateConstraints([labelConstraints.xConstraint, labelConstraints.yConstraint])
        
        // FIXME: Mispoisitioned Constraints
        let buttonConstraints = NSLayoutConstraint.generateConstraints(clockwiseButton, toItem: view, xMultiplier: 1.5, yMultiplier: 0.4)
        let widthConstraintClockwise = NSLayoutConstraint(item: clockwiseButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.2, constant: 0)
        let heightConstraintClockwise = NSLayoutConstraint(item: clockwiseButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.2, constant: 0)
        clockwiseButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(clockwiseButton)
        clockwiseButton.addTarget(self, action: "clockwise:", forControlEvents: .TouchUpInside)
        clockwiseButton.labelText = "Clockwise"
        NSLayoutConstraint.activateConstraints([buttonConstraints.xConstraint , buttonConstraints.yConstraint, widthConstraintClockwise, heightConstraintClockwise])
        
        // FIXME: Mispoisitioned Constraints
        let counterClockwiseButtonConstraints = NSLayoutConstraint.generateConstraints(counterClockwiseButton, toItem: view, xMultiplier: 0.4, yMultiplier: 0.4)
        let widthConstraintCounterClockwise = NSLayoutConstraint(item: counterClockwiseButton, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.2, constant: 0)
        let heightConstraintCounterClockwise = NSLayoutConstraint(item: counterClockwiseButton, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.2, constant: 0)

        counterClockwiseButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(counterClockwiseButton)
        counterClockwiseButton.addTarget(self, action: "counterClockwise:", forControlEvents: .TouchUpInside)
        counterClockwiseButton.labelText = "Counterclockwise"
        NSLayoutConstraint.activateConstraints([counterClockwiseButtonConstraints.xConstraint, counterClockwiseButtonConstraints.yConstraint, widthConstraintCounterClockwise, heightConstraintCounterClockwise])
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
