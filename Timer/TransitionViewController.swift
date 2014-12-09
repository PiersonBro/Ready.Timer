//
//  TransitionViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 11/29/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

class TransitionViewController: UIViewController {
    let effect: UIBlurEffect
    let backgroundView: UIVisualEffectView
    let contentView: UIVisualEffectView
    let label: UILabel = UILabel(frame: CGRect())
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        effect = UIBlurEffect(style: .Light)
        backgroundView = UIVisualEffectView(effect: effect)
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: effect)
        contentView = UIVisualEffectView(effect: vibrancyEffect)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .Custom
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Initilizer not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        
        view.addSubview(backgroundView)
        layout(backgroundView) { (backgroundView) in
            backgroundView.size == backgroundView.superview!.size
            backgroundView.center == backgroundView.center
        }
        
        view.addSubview(contentView)
        layout(contentView) { (contentView) in
            contentView.size == contentView.superview!.size
            contentView.center == contentView.superview!.center
        }


        let dismissButton: UIButton = UIButton.buttonWithType(.System) as UIButton
        dismissButton.titleLabel!.text = "Dismiss"
        dismissButton.setTitle("Dismiss", forState: .Normal)
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        contentView.addSubview(dismissButton)
        layout(dismissButton) { dismissButton in
            dismissButton.center == dismissButton.superview!.center
            dismissButton.width == dismissButton.superview!.width / 2
        }
        
        contentView.addSubview(label)
        layout(label) { label in
            label.centerX == label.superview!.centerX
            label.centerY == label.superview!.centerY / 2
            return
        }
        

        label.text = "30:00"
        label.font = UIFont.systemFontOfSize(160)
        let countUpTimer = CountUpTimerController(upperLimitInSeconds: 30)
        countUpTimer.activateWithBlock({ (elapsedTime) -> () in
            self.label.text = elapsedTime
        }, conclusionBlock: { (conclusionResult) -> () in
            
        })
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
