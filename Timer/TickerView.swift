//
//  TickerView.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import QuartzCore
import Cartography

private extension Position {
    static let staticCenter: Position = Position.Center((xMultiplier: 1, yMultiplier: 0.5))
    static let staticRight: Position = Position.Right((xMultiplier: 1.5, yMultiplier: 0.8))
    static let staticLeft: Position = Position.Left((xMultiplier: 0.5, yMultiplier: 0.8))
    static let staticBottom: Position = Position.Bottom((xMultiplier: 1, yMultiplier: 1.5))
    
    static func positionForMultipliers(xMultiplier: CGFloat, yMultiplier: CGFloat) -> Position? {
        return positionForMultipliers(Float(xMultiplier), yMultiplier: Float(yMultiplier))
    }
    
    static func positionForMultipliers(xMultiplier: Float, yMultiplier: Float) -> Position? {
        switch (xMultiplier, yMultiplier) {
        case (self.staticCenter.positionTuple.xMultiplier, self.staticCenter.positionTuple.yMultiplier):
            return self.staticCenter
        case (self.staticRight.positionTuple.xMultiplier, self.staticRight.positionTuple.yMultiplier):
            return self.staticRight
        case (self.staticLeft.positionTuple.xMultiplier, self.staticLeft.positionTuple.yMultiplier):
            return self.staticLeft
        case (self.staticBottom.positionTuple.xMultiplier, self.staticBottom.positionTuple.yMultiplier):
            return self.staticBottom
        default:
            return nil
        }
    }
}

class TickerView: UIView, UIDynamicAnimatorDelegate {
    // Subviews
    private var bottommostLabel: TickerLabel
    private var rightmostLabel: TickerLabel
    private var topmostLabel: TickerLabel
    private var leftmostLabel: TickerLabel
    
    private let leftDivider: UIView
    private let rightDivider: UIView
    private let leftEdgeDivider: UIView
    private let rightEdgeDivider: UIView
    
    private var labelConstraintsNeedUpdate: Bool = false

    private var speechCount: Int
    private var speechIndexToUpdate: Int
    
    // Strongly held animator objects
    private var animator: UIDynamicAnimator
    private let labels: [TickerLabel]
    
    let dataSource: TickerViewDataSource
    let delegate: TickerViewDelegate
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Initializer Not Supported")
    }

    override init(frame: CGRect) {
        fatalError("Initializer Not Supported")
    }
    
    init(frame: CGRect, dataSource: TickerViewDataSource, delegate: TickerViewDelegate) {
        bottommostLabel = TickerLabel(frame: CGRect())
        rightmostLabel = TickerLabel(frame: CGRect())
        topmostLabel = TickerLabel(frame: CGRect())
        leftmostLabel = TickerLabel(frame: CGRect())
        
        leftDivider = UIView(frame: CGRect())
        rightDivider = UIView(frame: CGRect())
        leftEdgeDivider = UIView(frame: CGRect())
        rightEdgeDivider = UIView(frame: CGRect())
        
        
        animator = UIDynamicAnimator()
        labels = [leftmostLabel, topmostLabel, rightmostLabel, bottommostLabel]
        speechCount = 0
        self.dataSource = dataSource
        self.delegate = delegate
        speechIndexToUpdate = 0;
        super.init(frame: frame)

        addSubview(leftDivider)
        layout(leftDivider, self) { (leftDivider, view) in
            leftDivider.centerX == view.centerX * 0.6
            leftDivider.centerY == view.centerY
            leftDivider.height == view.height
            leftDivider.width == view.width / 64
        }
        
        addSubview(rightDivider)
        layout(rightDivider, self) { (rightDivider, view) in
            rightDivider.centerX == view.centerX * 1.40
            rightDivider.centerY == view.centerY
            rightDivider.height == view.height
            rightDivider.width == view.width / 64
        }
        
        addSubview(leftEdgeDivider)
        layout(leftEdgeDivider, self) { (leftEdgeDivider, view) in
            leftEdgeDivider.centerX == view.centerX * 0.1
            leftEdgeDivider.centerY == view.centerY
            leftEdgeDivider.height == view.height
            leftEdgeDivider.width == view.width / 64
        }
        
        addSubview(rightEdgeDivider)
        layout(rightEdgeDivider, self) { (rightEdgeDivider, view) in
            rightEdgeDivider.centerX == view.centerX * 1.9
            rightEdgeDivider.centerY == view.centerY
            rightEdgeDivider.height == view.height
            rightEdgeDivider.width == view.width / 64
        }
        

        topmostLabel = configureLabel(topmostLabel, text: self.dataSource.stringForIndex(speechCount) ?? "E", positions: Position.staticCenter)
        topmostLabel.index = speechCount

        leftmostLabel = configureLabel(leftmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions: Position.staticLeft)
        leftmostLabel.index = speechCount
        bottommostLabel = configureLabel(bottommostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions: Position.staticBottom)
        bottommostLabel.index = speechCount
        rightmostLabel = configureLabel(rightmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions:Position.staticRight)
        rightmostLabel.index = speechCount
       
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        layer.masksToBounds = true
        backgroundColor =  UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        // FIXME: This leads to janky rotation animations, and should be fixed before release.
        contentMode = .Redraw
    }

    private func configureLabel(label: TickerLabel, text: String, positions: Position) -> TickerLabel {
        label.font = UIFont.systemFontOfSize(50)
        label.textColor = UIColor.cyanColor()
        label.text = text
        
        addSubview(label)
        layoutLabel(label, position: positions)

        return label
    }
    
   private func layoutLabel(label: TickerLabel, position: Position) {
        var xConstraint: NSLayoutConstraint? = nil
        var yConstraint: NSLayoutConstraint? = nil
        var leftConstraint: NSLayoutConstraint? = nil
        var rightConstraint: NSLayoutConstraint? = nil
    
        layout([label, rightDivider, leftDivider, rightEdgeDivider, leftEdgeDivider]) { (layoutProxies) in
            let label = layoutProxies[0]
            let rightDivider = layoutProxies[1]
            let leftDivider = layoutProxies[2]
            let rightEdgeDivider = layoutProxies[3]
            let leftEdgeDivider = layoutProxies[4]
            
            xConstraint = label.centerX == label.superview!.centerX * CGFloat(position.positionTuple.xMultiplier) ~ 750
            yConstraint = label.centerY == label.superview!.centerY * CGFloat(position.positionTuple.yMultiplier)
            
            switch position {
            case .Center:
                leftConstraint = label.left >= leftDivider.right
                rightConstraint = label.right <= rightDivider.left
            case .Bottom:
                leftConstraint = label.left <= leftDivider.right
                rightConstraint = label.right <= rightDivider.left
            case .Right:
                leftConstraint = label.left == rightDivider.right
                rightConstraint = label.right == rightEdgeDivider.right
            case .Left:
                leftConstraint = label.left == leftEdgeDivider.left
                rightConstraint = label.right == leftDivider.left
            }
        }
    
        xConstraint?.identifier = "X constraint for label: \(label.hash)"
        yConstraint?.identifier = "Y constraint for label: \(label.hash)"
        leftConstraint?.identifier = "Left Constraint for label: \(label.hash)"
        rightConstraint?.identifier = "Right Constraint for label: \(label.hash)"
    }
    
    override func drawRect(rect: CGRect) {
        let layers = self.layer.sublayers!
        for subLayer in layers {
            if subLayer.name != nil {
                switch subLayer.name! {
                case "leftLineShapeLayer":
                    subLayer.removeFromSuperlayer()
                case "rightLineShapeLayer":
                    subLayer.removeFromSuperlayer()
                default: break
                }
            }
        }
        
        let mask = CAShapeLayer()
        mask.frame = bounds;
        let point = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(point)
        bezierPath.addArcWithCenter(point, radius: rect.size.width / 2, startAngle:CGFloat(M_PI), endAngle: CGFloat(M_PI) * 2, clockwise: true)
        mask.path = bezierPath.CGPath
        layer.mask = mask
        
        let leftLineShapeLayer = CAShapeLayer()
        leftLineShapeLayer.name = "leftLineShapeLayer"
        let leftLinePath = UIBezierPath()
        leftLinePath.moveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
        leftLinePath.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
       
        leftLineShapeLayer.path = leftLinePath.CGPath
        leftLineShapeLayer.strokeColor = UIColor.cyanColor().CGColor
        leftLineShapeLayer.lineWidth = 5
        
        layer.addSublayer(leftLineShapeLayer)
        
        let rightLineShapeLayer = CAShapeLayer()
        rightLineShapeLayer.name = "rightLineShapeLayer"
        let rightLinePath = UIBezierPath()
        rightLinePath.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect)))
        rightLinePath.addLineToPoint(CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)))
        rightLinePath.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMinY(rect)))
        rightLineShapeLayer.path = rightLinePath.CGPath
        rightLineShapeLayer.strokeColor = UIColor.cyanColor().CGColor
        rightLineShapeLayer.lineWidth = 5
        layer.addSublayer(rightLineShapeLayer)
    }
    
    func rotateToNextSegment() {
        rotateWithSnapBehaviors(snapBehaviorsForLabelsAscending(true))
    }
    
    func rotateToPreviousSegment() {
        rotateWithSnapBehaviors(snapBehaviorsForLabelsAscending(false))
    }

    func rotateWithSnapBehaviors(snapBehaviors: [UISnapBehavior]) {
        animator.removeAllBehaviors()
        
        for snapBehavior in snapBehaviors {
            animator.addBehavior(snapBehavior)
        }
        
        let item = UIDynamicItemBehavior(items: labels)
        item.resistance = 150
        animator.addBehavior(item)
        labelConstraintsNeedUpdate = true
        setNeedsUpdateConstraints()
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
    }
    
    func snapBehaviorsForLabelsAscending(ascending: Bool) -> [UISnapBehavior] {
        var snapBehaviors: [UISnapBehavior] = []
        var reversedLabels: [TickerLabel]? = nil
        
        if !ascending {
            reversedLabels = labels.reverse()
        }
        
        enumerateLabels(reversedLabels ?? labels) { (label, nextLabel) in
            let snapBehavior = UISnapBehavior(item: label, snapToPoint: nextLabel.center)
            snapBehaviors.append(snapBehavior)
        }
        
        return snapBehaviors
    }
    
      func enumerateLabels(labelsToEnumerate: [TickerLabel], block: (label: TickerLabel, nextLabel: TickerLabel) -> Void) {
        for var i = 0; i < labelsToEnumerate.count; ++i {
            let label = labelsToEnumerate[i]
            var nextLabel: TickerLabel? = nil
            let nextIndex = i + 1
           
            if (nextIndex < labelsToEnumerate.count) {
                nextLabel = labelsToEnumerate[nextIndex]
            } else {
                nextLabel = labelsToEnumerate.first
            }

            block(label: label, nextLabel: nextLabel!)
        }
    }
    
    func makeDataSourceCalls() {
        var centerLabel: TickerLabel? = nil
        var rightLabel: TickerLabel? = nil
        var bottomLabel: TickerLabel? = nil
        
        for label in labels  {
            let constraints = self.positioningConstraintsForLabel(label, constraints: self.constraints)
            let result = Position.positionForMultipliers(constraints.xConstraint.multiplier, yMultiplier: constraints.yConstraint.multiplier)
            
            if let result = result {
                switch (result) {
                case .Center(_, _):
                    centerLabel = label
                case .Right(_, _):
                    rightLabel = label
                case .Bottom(_,_):
                    bottomLabel = label
                default:
                    break
                }
            }
        }
        
        guard let unwrappedLabelCenter = centerLabel, unwrappedLabelRight = rightLabel, unwrappedLabelBottom = bottomLabel else {
            fatalError("Couldn't find centerLabel, rightLabel, or bottomLabel")
        }
        
        self.delegate.tickerViewDidRotateStringAtIndexToRightPosition(unwrappedLabelRight.index)
        self.delegate.tickerViewDidRotateStringAtIndexToCenterPosition(unwrappedLabelCenter.index)
        
        if (self.dataSource.stringShouldBeChanged(unwrappedLabelBottom.index)) {
            let optionalSpeechName = dataSource.stringForIndex(++speechCount)
            let speechName: String
            
            if let name = optionalSpeechName {
                speechName = name
            } else {
                delegate.tickerViewDidRotateToLastSpeech(speechCount)
                speechCount = 0
                let firstName = dataSource.stringForIndex(speechCount)
                speechName = firstName ?? "E"
            }
            
            unwrappedLabelBottom.index = speechCount
            unwrappedLabelBottom.text = speechName
        }
    }
    override func updateConstraints() {
        if labelConstraintsNeedUpdate {
            labelConstraintsNeedUpdate = false
            let unmodifiedConstraints = constraints
            enumerateLabels(labels, block: { (label, nextLabel) in
                let newConstraints = self.positioningConstraintsForLabel(nextLabel, constraints: unmodifiedConstraints)
                let xMultiplier = newConstraints.xConstraint.multiplier
                let yMultiplier = newConstraints.yConstraint.multiplier
                let newPosition = Position.positionForMultipliers(Float(xMultiplier), yMultiplier: Float(yMultiplier))
                
                NSLayoutConstraint.deactivateConstraints(self.constraintsForLabel(label, superviewConstraints: unmodifiedConstraints))
                self.layoutLabel(label, position:newPosition!)
            })
            makeDataSourceCalls()
        }
        
        super.updateConstraints()
    }
    
    func constraintsForLabel(label: TickerLabel, superviewConstraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        var labelConstraints = [NSLayoutConstraint]()
        for constraint in superviewConstraints {
            let identifierNSString: NSString = constraint.identifier ?? ""
            if (identifierNSString.containsString(label.hash.description)) {
                labelConstraints.append(constraint)
            }
        }
        return labelConstraints
    }
    
    func positioningConstraintsForLabel(label: TickerLabel, constraints: [NSLayoutConstraint]) -> (xConstraint: NSLayoutConstraint, yConstraint: NSLayoutConstraint) {
        var xConstraint: NSLayoutConstraint? = nil
        var yConstraint: NSLayoutConstraint? = nil
        
        for constraint in constraints {
            if (xConstraint != nil && yConstraint != nil) {
                break
            }
            
            switch constraint.identifier ?? "" {
            case ("X constraint for label: \(label.hash)"):
                xConstraint = constraint
            case ("Y constraint for label: \(label.hash)"):
                yConstraint = constraint
            default:
                break
            }
        }
        
        return (xConstraint!, yConstraint!)
    }
}

protocol TickerViewDataSource {
    // Index - Starts from Zero .
    func stringForIndex(index: Int) -> String?
    func stringShouldBeChanged(index: Int) -> Bool
}

protocol TickerViewDelegate {
    func tickerViewDidRotateStringAtIndexToCenterPosition(index: Int)
    func tickerViewDidRotateStringAtIndexToRightPosition(index: Int)
    func tickerViewDidRotateToLastSpeech(index: Int)
}
