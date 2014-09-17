//
//  ViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TickerViewDataSource, TickerViewDelegate {
    let tickerView: TickerView?
    let timerLabel: UILabel
    let debateRoundManager: DebateRoundManager?
    
    required init(coder aDecoder: NSCoder) {
        timerLabel = UILabel(frame: CGRect())
        debateRoundManager = DebateRoundManager(type: .TeamPolicy)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func clockwise(sender: AnyObject) {
        tickerView!.rotateToNextSegment()
    }
    
    @IBAction func counterClockwise(sender: AnyObject) {
        tickerView!.rotateToPreviousSegment()
    }
    
    func stringForIndex(index: Int) -> String {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        return speech.name
    }
    
    func tickerViewDidRotateStringAtIndexToRightPosition(index: Int) {
        debateRoundManager?.markSpeechAsConsumedAtIndex(index)
    }
    
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int) {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        println(speech.speechType)
        println(speech.name)
        timerLabel.text = "\(speech.speechType.durationOfSpeech()):00"
    }
    
    func stringShouldBeChanged(index: Int) -> Bool {
        let speech = debateRoundManager!.getSpeechAtIndex(index)
        if (speech.consumed) {
            return true
        }
        
        return false
    }
}
