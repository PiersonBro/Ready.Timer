//
//  CreateRoundViewController.swift
//  Timer
//
//  Created by EandZ on 11/21/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

enum TimerItem: String {
    case Infinite
    case Overtime
    case CountUp = "Count Up"
    case CountDown = "Count Down"
    
    var timerKind: TimerKind {
        switch self {
        case .Infinite:
            return .InfiniteTimer
        case .Overtime:
            return .OvertimeTimer
        case .CountUp:
            return .CountUpTimer
        case .CountDown:
            return .CountDownTimer
        }
    }
}

class CreateRoundViewController: UIViewController, TickerViewDataSource, UITextFieldDelegate {
    var tickerView: TickerView? = nil
    let textLabel = UILabel(frame: CGRect())
    let keyboardView = UIView(frame: CGRect())
    let pickerView = UIPickerView(frame: CGRect())
    let textBox = UITextField(frame: CGRect())
    let segmentedControl = UISegmentedControl(items: [TimerItem.CountDown.rawValue, TimerItem.CountUp.rawValue, TimerItem.Overtime.rawValue, TimerItem.Infinite.rawValue])
    let pickerViewHandler = PickerViewHandler()
    let enterCircleButton = CircleButton(frame: CGRect())
    let finishCircleButton = CircleButton(frame: CGRect())
    
    let plistCreator = PlistCreator()
    
    // STATE:
    var keyboardConstraint: NSLayoutConstraint? = nil
    var constraint = [NSLayoutConstraint]()
    var centerToFind = CGPoint()

    init() {
        super.init(nibName: nil, bundle: nil)
        tickerView = TickerView(frame: CGRect(), dataSource: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        view.addSubview(tickerView!)
        view.addSubview(keyboardView)
        
        constrain(tickerView!, view) { (tickerView, view) in
            tickerView.centerX == view.centerX
            tickerView.centerY == view.centerY * 2 ~ 750
            tickerView.width == view.width * 1 ~ 750
            tickerView.width == view.width * 0.8 ~ 500
            tickerView.height == tickerView.width
            tickerView.height <= view.height * 0.8
        }
        
        view.addSubview(segmentedControl)
        constrain(segmentedControl) { segmentedControl in
            segmentedControl.centerX == segmentedControl.superview!.centerX
            segmentedControl.top == segmentedControl.superview!.top + 20
            segmentedControl.leading == segmentedControl.superview!.leading
            segmentedControl.trailing == segmentedControl.superview!.trailing
        }
        segmentedControl.tintColor = .purpleColor()
        segmentedControl.addTarget(self, action: "segmentedControlTapped:", forControlEvents: .ValueChanged)
        
        pickerView.delegate = pickerViewHandler
        pickerView.dataSource = pickerViewHandler
        addPickerView()
        
        view.addSubview(enterCircleButton)
        constrain(enterCircleButton, tickerView!) { circleButton, tickerView in
            circleButton.centerX == circleButton.superview!.centerX * 1.5
            circleButton.centerY == tickerView.top - 100
            circleButton.width == circleButton.superview!.width * 0.2
            circleButton.height == circleButton.width
        }
        enterCircleButton.labelText = "Next"
        enterCircleButton.addTarget(self, action: "enterButtonTapped", forControlEvents: .TouchUpInside)
        
        view.addSubview(finishCircleButton)
        constrain(finishCircleButton, tickerView!) { finishCircleButton, tickerView in
            finishCircleButton.centerX == finishCircleButton.superview!.centerX * 0.5
            finishCircleButton.centerY == tickerView.top - 100
            finishCircleButton.width == finishCircleButton.superview!.width * 0.2
            finishCircleButton.height == finishCircleButton.width
        }
        finishCircleButton.labelText = "Finish"
        finishCircleButton.addTarget(self, action: "finishButtonTapped", forControlEvents: .TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        tickerView?.rotateToNextSegment()
    }

    func stringForIndex(index: Int) -> String? {
        return "    "
    }

    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int) {
        textBox.delegate = self
        textBox.backgroundColor = .grayColor()
        textBox.placeholder = "Insert Timer Name"
        view.addSubview(textBox)
        
        let label: UILabel
        if centerToFind == CGPoint() {
            label = tickerView?.subviews[0...5].last as! UILabel
            centerToFind = label.center
        } else {
             let views = tickerView!.subviews.filter { view in
                view.center == centerToFind
            }
            label = views.last as! UILabel
        }
        constraint.forEach {
            $0.active = false
        }

        constrain(textBox, label) { textBox, label in
            constraint = textBox.center == label.center
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func tickerViewDidRotateToLastSpeech(index: Int) {

    }

    func keyboardWillShow(notification: NSNotification) {
        let windows = UIApplication.sharedApplication().windows
        let keyboardWindow = windows[2]
        let visibleRect = CGRectIntersection(tickerView!.frame, tickerView!.superview!.bounds);

        pickerView.hidden = true
        if let _ = keyboardConstraint {
            keyboardView.frame = keyboardWindow.subviews[0].subviews.first!.frame
            view.setNeedsUpdateConstraints()
            keyboardWindow.subviews[0].subviews.first!.setNeedsUpdateConstraints()
        } else {
            keyboardView.frame = keyboardWindow.subviews[0].subviews.first!.frame
            constrain(keyboardView, tickerView!) { keyboardView, tickerView in
                keyboardConstraint = tickerView.bottom == keyboardView.top + visibleRect.height
            }
            keyboardConstraint?.identifier = "Keyboard Constraint"
        }
        animateWithKeyboardLayout(notification.userInfo)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardConstraint?.active = false
        keyboardConstraint = nil
        pickerView.hidden = false
        animateWithKeyboardLayout(notification.userInfo)
    }
    
    func animateWithKeyboardLayout(userInfo: [NSObject: AnyObject]?) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    func segmentedControlTapped(segmentedControl: UISegmentedControl) {
        let item = TimerItem(rawValue: segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex)!)!
        switch item {
            case .Infinite:
                pickerView.removeFromSuperview()
            default:
                if !pickerView.isDescendantOfView(view) {
                    addPickerView()
                }
        }
    }
    
    func addPickerView() {
        view.addSubview(pickerView)
        constrain(pickerView, segmentedControl, tickerView!) { pickerView, segmentedControl, tickerView in
            pickerView.centerX == pickerView.superview!.centerX
            pickerView.centerY == pickerView.superview!.centerY / 2
        }
    }

    func enterButtonTapped() {
        let duration = pickerViewHandler.calculatedDurationFromPickerView(pickerView)
        let identifier = textBox.text ?? ""
        let index: Int?
        if segmentedControl.selectedSegmentIndex != -1 {
           index = segmentedControl.selectedSegmentIndex
        } else {
            index = nil
        }
        
        if let newIndex = index, let title = segmentedControl.titleForSegmentAtIndex(newIndex) where identifier != "" {
            let typeOfTimer = TimerItem(rawValue: title)!.timerKind
            if typeOfTimer != .InfiniteTimer && duration == 0 {
                rejectAnimation()
            } else {
                plistCreator.addTimer(ofType: typeOfTimer, identifier: identifier, durationInSeconds: duration)
                textBox.text = ""
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                tickerView?.rotateToNextSegment()
            }
        } else {
            rejectAnimation()
        }
    }
    
    func rejectAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let initialValue = NSValue(CATransform3D: CATransform3DMakeTranslation(-2.0, 0.0, 0.0))
        let finalValue = NSValue(CATransform3D: CATransform3DMakeTranslation(2.0, 0.0, 0.0))
        animation.values = [initialValue, finalValue]
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = 2.0
        enterCircleButton.layer.addAnimation(animation, forKey:nil)
    }
    
    func finishButtonTapped() {
        let controller = UIAlertController(title: "Enter Round Name", message: nil, preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler(nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .Default) { action in
            let text = controller.textFields![0].text!
            self.plistCreator.finish(name: text)
            let selectVC = SelectRoundViewController(rounds: Round.allRounds())
            selectVC.modalPresentationStyle = .FormSheet
            self.presentViewController(selectVC, animated: true, completion: nil)
        }
        controller.addAction(cancelAction)
        controller.addAction(doneAction)
        controller.preferredAction = doneAction
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

class PickerViewHandler: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let dataSource: [[String]]
    
    override init() {
        let minutes = (0...59).map { String($0) }
        let tenths = (0...5).map { String($0) }
        let seconds = (0...9).map { String($0) }
        dataSource = [minutes, tenths, seconds]
        super.init()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = dataSource[component][row]
        return title
    }
    func calculatedDurationFromPickerView(pickerView: UIPickerView) -> Int {
        let minutes = Int(dataSource[0][pickerView.selectedRowInComponent(0)])! * 60
        let tenths = Int(dataSource[1][pickerView.selectedRowInComponent(1)])! * 10
        let seconds = Int(dataSource[2][pickerView.selectedRowInComponent(2)])!
        
        return minutes + tenths + seconds
    }
}
