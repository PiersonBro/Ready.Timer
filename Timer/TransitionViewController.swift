//
//  TransitionViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 11/29/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography
import TimerKit

private extension Position {
    static let staticLeft: Position = .Left((xMultiplier: 0.5, yMultiplier: 0.5))
    static let staticMiddle: Position = .Center((xMultiplier: 1, yMultiplier: 0.5))
    static let staticRight: Position = .Right((xMultiplier: 1.5, yMultiplier: 0.5))
}

class TransitionViewController: UIViewController, UIDynamicAnimatorDelegate {
    // MARK: Views
    let blurView: UIVisualEffectView
    let contentView: UIView
    
    let middleLabel: UILabel = UILabel(frame: CGRect())
    
    let circleButton: CircleButton = CircleButton(frame: CGRect())

    let leftDivider:  UIView = UIView(frame: CGRect())
    let rightDivider: UIView = UIView(frame: CGRect())
    
    let countUpTimer: Timer<CountUpBlueprint>

    private let startPrepTimeString: String = "Start Pep Time"
    private let stopPrepTimeString: String = "Stop Prep Time"
    private let finishedPepTimeString: String = "Prep Time Expired"
    
    init(countUpTimer: Timer<CountUpBlueprint>) {
        self.countUpTimer = countUpTimer
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        contentView = blurView.contentView
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .Custom
        view.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Initilizer not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        layout(blurView) { backgroundView in
            backgroundView.size == backgroundView.superview!.size
            backgroundView.center == backgroundView.center
        }
        
        view.addSubview(blurView)
        layout(blurView) { contentView in
            contentView.size == contentView.superview!.size
            contentView.center == contentView.superview!.center
        }
        
        contentView.addSubview(leftDivider)
        layout(leftDivider) { leftDivider in
            leftDivider.centerX == leftDivider.superview!.centerX * 0.67
            leftDivider.centerY == leftDivider.superview!.centerY * 0.5
            leftDivider.height == leftDivider.superview!.height / 4
            leftDivider.width == leftDivider.superview!.width / 64
        }
        
        contentView.addSubview(rightDivider)
        layout(rightDivider) { rightDivider in
            rightDivider.centerY == rightDivider.superview!.centerY * 0.5
            rightDivider.centerX == rightDivider.superview!.centerX * 1.35
            rightDivider.height == rightDivider.superview!.height / 4
            rightDivider.width == rightDivider.superview!.width / 64
        }

        setupCircleButton()
        setupLabel(middleLabel, position: Position.staticMiddle)
    }

    func startTimerWithLabel(label: UILabel) {
        countUpTimer.onTick { elapsedTime in
                label.text = String.formattedStringForDuration(elapsedTime)
            } .onConclusion { conclusionStatus in
                if conclusionStatus == .Finish {
                    self.circleButton.labelText = self.finishedPepTimeString
                }
        }.activate()
    
    }

    
    func setupCircleButton() {
        circleButton.labelText = {
            // The `TimerStatus` in front of the .Finished, appears to be a type inferenceing bug. Not sure how to reproduce it though.
            if self.countUpTimer.status == TimerStatus.Finished {
                return self.finishedPepTimeString
            } else {
                return self.startPrepTimeString
            }
        }()
        
        circleButton.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        contentView.addSubview(circleButton)
        layout(circleButton) { circleButton in
            circleButton.center == circleButton.superview!.center
            circleButton.size == circleButton.superview!.size / 4
        }
    }
    
    func setupLabel(label: UILabel, position: Position) {
        contentView.addSubview(label)
        constrain(label) { label in
            label.centerX == label.superview!.centerX * CGFloat(position.positionTuple.xMultiplier) ~ 750
            label.centerY == label.superview!.centerY * CGFloat(position.positionTuple.yMultiplier)
        }

        label.text = {
            switch position {
                case .Center(_,_):
                    let duration: Int = {
                        if self.countUpTimer.status == .Finished || self.countUpTimer.status == .Inactive {
                            return self.countUpTimer.blueprint.startingValue
                        } else {
                            return self.countUpTimer.pauseDuration!
                        }
                    }()
                    return .formattedStringForDuration(duration)
                default:
                    return "0:00"
            }
        }()
        
        label.font = UIFont.systemFontOfSize(160)
        label.textAlignment = .Center
        label.baselineAdjustment = .AlignCenters
        label.adjustsFontSizeToFitWidth = true
        
        switch position {
            case .Right(_,_):
                constrain(label, rightDivider) { rightLabel, rightDivider in
                    rightLabel.right == rightLabel.superview!.right
                    rightLabel.left == rightDivider.right
                }
            case .Left(_, _):
                constrain(label, leftDivider) { leftLabel, leftDivider in
                    leftLabel.left == leftLabel.superview!.left
                    leftLabel.right == leftDivider.left
                }
            case .Center(_, _):
                constrain(label, leftDivider, rightDivider) { middleLabel, leftDivider, rightDivider  in
                    middleLabel.right == rightDivider.left
                    middleLabel.left == leftDivider.right
                }
            default:
                break
        }
    }
    
    @objc private func buttonTapped(circleButton: CircleButton) {
        switch circleButton.labelText ?? "" {
            case startPrepTimeString:
                startTimerWithLabel(middleLabel)
                circleButton.labelText = stopPrepTimeString
            case stopPrepTimeString:
                countUpTimer.concludeWithStatus(.Pause)
                dismissViewControllerAnimated(true, completion: nil)
            case startPrepTimeString:
                break
            case finishedPepTimeString:
                dismissViewControllerAnimated(true, completion: nil)
            default:
                break
        }
    }
}
