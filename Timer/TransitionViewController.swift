//
//  TransitionViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 11/29/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

class TransitionViewController: UIViewController, UIDynamicAnimatorDelegate {
    // MARK: Views
    
    let backgroundView: UIVisualEffectView
    let contentView: UIVisualEffectView
    
    let leftLabel: UILabel = UILabel(frame: CGRect())
    let rightLabel: UILabel = UILabel(frame: CGRect())
    
    let countUpTimer: CountUpTimerController
    let animator: UIDynamicAnimator
    
    let rightTapGestureRecognizer: UITapGestureRecognizer
    let leftTapGestureRecognizer: UITapGestureRecognizer
    
    init(countUpTimer: CountUpTimerController) {
        self.countUpTimer = countUpTimer
        
        let effect = UIBlurEffect(style: .Light)
        backgroundView = UIVisualEffectView(effect: effect)
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: effect)
        contentView = UIVisualEffectView(effect: vibrancyEffect)
        
        animator = UIDynamicAnimator(referenceView: contentView)
        rightTapGestureRecognizer = UITapGestureRecognizer()
        leftTapGestureRecognizer = UITapGestureRecognizer()
        
        super.init(nibName: nil, bundle: nil)
        
        rightTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "snapLabelToCenter:")
        leftTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "snapLabelToCenter:")
        
        rightLabel.userInteractionEnabled = true
        rightLabel.addGestureRecognizer(rightTapGestureRecognizer)
        leftLabel.userInteractionEnabled = true
        leftLabel.addGestureRecognizer(leftTapGestureRecognizer)
        
        animator.delegate = self
        modalPresentationStyle = .Custom
        view.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Initilizer not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        layout(backgroundView) { backgroundView in
            backgroundView.size == backgroundView.superview!.size
            backgroundView.center == backgroundView.center
        }
        
        view.addSubview(contentView)
        layout(contentView) { contentView in
            contentView.size == contentView.superview!.size
            contentView.center == contentView.superview!.center
        }

        setupDismissButton()
        setupLeftLabel()
        setupRightLabel()
    }
    
    func snapLabelToCenter(gestureRecognizer: UIGestureRecognizer) {
        let label = gestureRecognizer.view! as UILabel
        let snapBehavior = UISnapBehavior(item: label, snapToPoint: CGPoint(x: contentView.center.x, y: label.center.y))
        animator.addBehavior(snapBehavior)

        if label == rightLabel {
            countUpTimer.concludeWithStatus(.ResetToPaused)
            startTimerWithLabel(label)
            fadeViewToBlack(leftLabel)
        } else {
            fadeViewToBlack(rightLabel)
        }
    }
    
    func fadeViewToBlack(view: UILabel) {
        // FIXME: Use an actual animation
        view.alpha = 0.0
    }
    
    func startTimerWithLabel(label: UILabel) {
        countUpTimer.activateWithBlock({ elapsedTime in
            label.text = elapsedTime
        }, conclusionBlock: { result in
            switch result.conclusionStatus {
                case .Finished:
                    println("Finished")
                case .Paused:
                    println("Paused")
                case .Reset:
                    println("Reset")
                case .ResetToPaused:
                    println("No need to do anything this is a stupid API")
            }
        })
    }
    
    func setupDismissButton() {
        let dismissButton = CircleButton(frame: CGRect())
        dismissButton.labelText = "Stop Prep Time"
        dismissButton.addTarget(self, action: "pauseAndDismiss", forControlEvents: .TouchUpInside)
        contentView.addSubview(dismissButton)
        layout(dismissButton) { dismissButton in
            dismissButton.center == dismissButton.superview!.center
            dismissButton.size == dismissButton.superview!.size / 4
        }
    }
    
    func setupLeftLabel() {
        contentView.addSubview(leftLabel)
        layout(leftLabel) { leftLabel in
            leftLabel.centerX == leftLabel.superview!.centerX / 2
            leftLabel.centerY == leftLabel.superview!.centerY / 2
        }
        
        leftLabel.text = "0:00"
        leftLabel.font = UIFont.systemFontOfSize(160)
        startTimerWithLabel(leftLabel)
    }
    
    func setupRightLabel() {
        contentView.addSubview(rightLabel)
        rightLabel.font = UIFont.systemFontOfSize(160)
        layout(rightLabel) { rightLabel in
            rightLabel.centerX == rightLabel.superview!.centerX * 1.5
            rightLabel.centerY == rightLabel.superview!.centerY / 2
        }
        
        rightLabel.text = "0:00"
    }
    
    // MARK: Interactivity
    func pauseAndDismiss() {
        countUpTimer.concludeWithStatus(.Paused)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
