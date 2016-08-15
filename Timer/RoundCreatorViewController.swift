//
//  CreateRoundViewController.swift
//  Timer
//
//  Created by EandZ on 11/21/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography
import CloudKit

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
    var constraints = [NSLayoutConstraint]()
    var centerToFind = CGPoint()
    let theme: ColorTheme
    
    init(theme: ColorTheme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
        tickerView = TickerView(dataSource: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.backgroundColor
        view.tintColor = theme.dominantTheme
        tickerView?.accentColor = theme.accentColor
        enterCircleButton.accentColor = theme.accentColor
        finishCircleButton.accentColor = theme.accentColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: theme.accentColor], for: .selected)

        view.addSubview(tickerView!)
        view.addSubview(keyboardView)
        
        constrain(tickerView!, view) { (tickerView, view) in
            tickerView.centerX == view.centerX
            (tickerView.centerY == view.centerY * 2) ~ LayoutPriority(750)
            (tickerView.width == view.width * 1) ~ LayoutPriority(750)
            (tickerView.width == view.width * 0.8) ~ 500
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
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped(_:)), for: .valueChanged)
        view.addSubview(enterCircleButton)
        constrain(enterCircleButton, tickerView!) { circleButton, tickerView in
            circleButton.centerX == circleButton.superview!.centerX * 1.5
            circleButton.centerY == tickerView.top - 100
            circleButton.width == circleButton.superview!.width * 0.2
            circleButton.height == circleButton.width
        }
        enterCircleButton.labelText = "Next"
        enterCircleButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        
        view.addSubview(finishCircleButton)
        constrain(finishCircleButton, tickerView!) { finishCircleButton, tickerView in
            finishCircleButton.centerX == finishCircleButton.superview!.centerX * 0.5
            finishCircleButton.centerY == tickerView.top - 100
            finishCircleButton.width == finishCircleButton.superview!.width * 0.2
            finishCircleButton.height == finishCircleButton.width
        }
        finishCircleButton.labelText = "Cancel"
        finishCircleButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        
        pickerView.delegate = pickerViewHandler
        pickerView.dataSource = pickerViewHandler
        addPickerView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tickerView?.rotateToNextSegment()
    }

    func stringForIndex(_ index: Int) -> String? {
        return "    "
    }

    func tickerViewDidRotateStringAtIndexToCenterPosition(_ index: Int, wasDragged: Bool, wasLast: Bool) {
        textBox.delegate = self
        textBox.backgroundColor = theme.accentColor
        textBox.placeholder = "Insert Timer Name"
        textBox.textAlignment = .center
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
        constraints.forEach {
            $0.isActive = false
        }

        constrain(textBox, label) { textBox, label in
            constraints = textBox.center == label.center
        }
        textBox.inputAssistantItem.leadingBarButtonGroups = []
        textBox.inputAssistantItem.trailingBarButtonGroups = []
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        
        func isExternalKeyboard() -> Bool {
            let kbFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
            let kb = view.convert(kbFrame!, from: view)
            let height = view.superview!.superview!.frame.size.height
            if kb.origin.y + kb.size.height > height {
                return true
            } else {
                return false
            }
        }
        
        let windows = UIApplication.shared.windows
        let keyboardWindow = windows[2]
        if !isExternalKeyboard() {
            let visibleRect = tickerView!.frame.intersection(tickerView!.superview!.frame);
            print(tickerView?.frame.height)
            print(visibleRect.height / 7)
            pickerView.isHidden = true
            pickerViewConstraint?.isActive = false
            if let _ = keyboardConstraint {
                keyboardView.frame = keyboardWindow.subviews[0].subviews.first!.frame
                view.setNeedsUpdateConstraints()
                keyboardWindow.subviews[0].subviews.first!.setNeedsUpdateConstraints()
            } else {
                keyboardView.frame = keyboardWindow.subviews[0].subviews.first!.frame
                constrain(keyboardView, tickerView!) { keyboardView, tickerView in
                    //FIXME: This only works for iPad 2.
                    keyboardConstraint = tickerView.bottom == keyboardView.top + (visibleRect.height / 6)
                }
                keyboardConstraint?.identifier = "Keyboard Constraint"
            }
            animateWithKeyboardLayout((notification as NSNotification).userInfo as [NSObject : AnyObject]?)
        }
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardConstraint = nil
        pickerView.isHidden = false
        animateWithKeyboardLayout((notification as NSNotification).userInfo as [NSObject : AnyObject]?)
        pickerViewConstraint?.isActive = true
    }
    
    func animateWithKeyboardLayout(_ userInfo: [NSObject: AnyObject]?) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((userInfo![UIKeyboardAnimationDurationUserInfoKey as NSString]! as AnyObject).doubleValue)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: (userInfo![UIKeyboardAnimationCurveUserInfoKey as NSString]! as AnyObject).intValue)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    func segmentedControlTapped(_ segmentedControl: UISegmentedControl) {
        let item = TimerItem(rawValue: segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!)!
        switch item {
            case .Infinite:
                pickerView.removeFromSuperview()
            default:
                if !pickerView.isDescendant(of: view) {
                    addPickerView()
                }
        }
    }
    
    var pickerViewConstraint: NSLayoutConstraint? = nil
    func addPickerView() {
        view.addSubview(pickerView)
        constrain(pickerView, segmentedControl) { pickerView, segmentedControl in
            pickerView.centerX == pickerView.superview!.centerX
            pickerView.centerY == pickerView.superview!.centerY / 2
        }
        constrain(pickerView, finishCircleButton) { pickerView, finishCircleButton in
            pickerViewConstraint = pickerView.bottom == finishCircleButton.top
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
        
        if let newIndex = index, let typeOfTimer = TimerItem(rawValue: segmentedControl.titleForSegment(at: newIndex) ?? "")?.timerKind, identifier != "" && (duration != 0 || typeOfTimer == .InfiniteTimer) {
            
            if finishCircleButton.labelText == "Cancel" {
                finishCircleButton.labelText = "Finish"
            }
            
            if textBox.isFirstResponder {
                view.endEditing(true)
            }
            
            plistCreator.addTimer(ofType: typeOfTimer, identifier: identifier, durationInSeconds: duration)
            textBox.text = ""
            pickerView.selectRow(0, inComponent: 0, animated: true)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.selectRow(0, inComponent: 2, animated: true)
            tickerView?.rotateToNextSegment()
        } else {
            rejectAnimation()
        }
    }
    
    func rejectAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let initialValue = NSValue(caTransform3D: CATransform3DMakeTranslation(-2.0, 0.0, 0.0))
        let finalValue = NSValue(caTransform3D: CATransform3DMakeTranslation(2.0, 0.0, 0.0))
        animation.values = [initialValue, finalValue]
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = 2.0
        enterCircleButton.layer.add(animation, forKey:nil)
    }
    
    func finishButtonTapped() {
        if finishCircleButton.labelText == "Finish" {
            let controller = UIAlertController(title: "Enter Round Name", message: nil, preferredStyle: .alert)
            controller.addTextField(configurationHandler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let doneAction = UIAlertAction(title: "Done", style: .default) { action in
                let text = controller.textFields![0].text!
                let didFinish = self.plistCreator.finish(name: text)
                if didFinish {
                    let round = Round.roundForName(text)!
                    let pVC = self.presentingViewController!
                    self.presentingViewController?.dismiss(animated: true) {
                        (pVC as! RoundCollectionViewController).addRound(round)
                    }
                }
            }
            controller.addAction(cancelAction)
            controller.addAction(doneAction)
            controller.preferredAction = doneAction
            present(controller, animated: true, completion: nil)
        } else {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.window?.rootViewController!.dismiss(animated: true, completion: nil)
        }
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = dataSource[component][row]
        return title
    }
    
    func calculatedDurationFromPickerView(_ pickerView: UIPickerView) -> Int {
        let minutes = Int(dataSource[0][pickerView.selectedRow(inComponent: 0)])! * 60
        let tenths = Int(dataSource[1][pickerView.selectedRow(inComponent: 1)])! * 10
        let seconds = Int(dataSource[2][pickerView.selectedRow(inComponent: 2)])!
        
        return minutes + tenths + seconds
    }
}
