//
//  TickerView.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import QuartzCore

private struct LabelPositions {
    static let Center: (xMultiplier: CGFloat, yMultiplier: CGFloat) = (xMultiplier: 1, yMultiplier: 0.5)
    static let Right: (xMultiplier: CGFloat, yMultiplier: CGFloat) = (xMultiplier: 1.5, yMultiplier: 0.7)
    static let Left: (xMultiplier: CGFloat, yMultiplier: CGFloat) = (xMultiplier: 0.5, yMultiplier: 0.7)
    static let Bottom: (xMultiplier: CGFloat, yMultiplier: CGFloat) = (xMultiplier: 1, yMultiplier:1.5)
    
    static func labelPositionsForMultipliers(xMultiplier: CGFloat, yMultiplier: CGFloat) -> (xMultiplier: CGFloat, yMultiplier: CGFloat)? {
        switch (xMultiplier, yMultiplier) {
            case (LabelPositions.Center.xMultiplier, LabelPositions.Center.yMultiplier):
                return LabelPositions.Center
            case (LabelPositions.Right.xMultiplier, LabelPositions.Right.yMultiplier):
                return LabelPositions.Right
            case (LabelPositions.Left.xMultiplier, LabelPositions.Left.yMultiplier):
                return LabelPositions.Left
            case (LabelPositions.Bottom.xMultiplier, LabelPositions.Bottom.yMultiplier):
                return LabelPositions.Bottom
            default:
                return nil
        }
    }
}

class TickerView: UIView {
    // Subviews
    private let bottommostLabel: TickerLabel
    private let rightmostLabel: TickerLabel
    private let topmostLabel: TickerLabel
    private let leftmostLabel: TickerLabel

    private var currentlyInvisibleLabel: TickerLabel {
        var invisibleLabel: TickerLabel? = nil
            let mask: CAShapeLayer = layer.mask as CAShapeLayer
            let bezierPath: UIBezierPath = UIBezierPath(CGPath: mask.path)
            for label in labels {
                if !bezierPath.containsPoint(label.center) {
                    invisibleLabel = label
                    break
                }
            }
            
            return invisibleLabel!
    }
    
    private var labelConstraintsNeedUpdate: Bool

    private var speechCount: Int
    private var speechIndexToUpdate: Int
    
    // Strongly held animator objects
    private let animator: UIDynamicAnimator
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
        
        animator = UIDynamicAnimator()
        labels = [leftmostLabel, topmostLabel, rightmostLabel, bottommostLabel]
        labelConstraintsNeedUpdate = false
        speechCount = 0
        self.dataSource = dataSource
        self.delegate = delegate
        speechIndexToUpdate = 0;
        super.init(frame: frame)
        
        topmostLabel = configureLabel(topmostLabel, text: self.dataSource.stringForIndex(speechCount) ?? "E", xMultiplier: LabelPositions.Center.xMultiplier, yMultiplier: LabelPositions.Center.yMultiplier)
        self.delegate.tickerViewDidRotateStringAtIndexToCenterPosition(speechCount)
        topmostLabel.index = speechCount

        leftmostLabel = configureLabel(leftmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", xMultiplier: LabelPositions.Left.xMultiplier, yMultiplier: LabelPositions.Left.yMultiplier)
        leftmostLabel.index = speechCount
        bottommostLabel = configureLabel(bottommostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", xMultiplier: LabelPositions.Bottom.xMultiplier, yMultiplier: LabelPositions.Bottom.yMultiplier)
        bottommostLabel.index = speechCount
        rightmostLabel = configureLabel(rightmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", xMultiplier: LabelPositions.Right.xMultiplier, yMultiplier: LabelPositions.Right.yMultiplier)
        rightmostLabel.index = speechCount
       
        animator = UIDynamicAnimator(referenceView: self)!
        layer.masksToBounds = true
        backgroundColor =  UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
    }
    
    func configureLabel(label: TickerLabel, text: String, xMultiplier: CGFloat, yMultiplier: CGFloat) -> TickerLabel {
        label.font = UIFont.systemFontOfSize(30)
        label.textColor = UIColor.cyanColor()
        label.text = text
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        let  constraints = NSLayoutConstraint.generateConstraints(label, toItem: self, xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        addSubview(label)
        NSLayoutConstraint.activateConstraints([constraints.xConstraint, constraints.yConstraint])
        return label
    }
    
    override func drawRect(rect: CGRect) {
        let mask = CAShapeLayer()
        mask.frame = bounds;
        let point = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(point)
        bezierPath.addArcWithCenter(point, radius: rect.size.width / 2, startAngle:CGFloat(M_PI), endAngle: CGFloat(M_PI) * 2, clockwise: true)
        mask.path = bezierPath.CGPath
        layer.mask = mask
        
        let leftLineShapeLayer = CAShapeLayer()
        let leftLinePath = UIBezierPath()
        leftLinePath.moveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
        leftLinePath.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
       
        leftLineShapeLayer.path = leftLinePath.CGPath
        leftLineShapeLayer.strokeColor = UIColor.cyanColor().CGColor
        leftLineShapeLayer.lineWidth = 5
        
        layer.addSublayer(leftLineShapeLayer)
        
        let rightLineShapeLayer = CAShapeLayer()
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
        
        let item = UIDynamicItemBehavior(items: labels)!
        item.resistance = 150
        animator.addBehavior(item)
        labelConstraintsNeedUpdate = true
        setNeedsUpdateConstraints()
    }
    
    func snapBehaviorsForLabelsAscending(ascending: Bool) -> [UISnapBehavior] {
        var snapBehaviors: [UISnapBehavior] = []
        var reversedLabels: [TickerLabel]? = nil
        
        if !ascending {
            reversedLabels = labels.reverse()
        }
        
        enumerateLabels(reversedLabels ?? labels) { (label, nextLabel) in
            let snapBehavior = UISnapBehavior(item: label, snapToPoint: nextLabel.center)
            snapBehaviors += [snapBehavior]
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
        for label in labels  {
            let constraints = self.constraintsForLabel(label, constraints: self.constraints() as [NSLayoutConstraint])
            let result = LabelPositions.labelPositionsForMultipliers(constraints.xConstraint.multiplier, yMultiplier: constraints.yConstraint.multiplier)
            let center = LabelPositions.Center
            let layer = label.layer.presentationLayer() as CALayer

            if (result!.xMultiplier == center.xMultiplier && result!.yMultiplier == center.yMultiplier) {
                self.delegate.tickerViewDidRotateStringAtIndexToCenterPosition(label.index)
            } else if  (result!.xMultiplier == LabelPositions.Right.xMultiplier && result!.yMultiplier == LabelPositions.Right.yMultiplier) {
                self.delegate.tickerViewDidRotateStringAtIndexToRightPosition(label.index)
            }
        }
        
        if (self.dataSource.stringShouldBeChanged(currentlyInvisibleLabel.index)) {
            let optionalSpeechName = dataSource.stringForIndex(++speechCount)
            var speechName = ""
            
            if let name = optionalSpeechName {
                speechName = name
            } else {
                delegate.tickerViewDidRotateToLastSpeech(speechCount)
                speechCount = 0
                let firstName = dataSource.stringForIndex(speechCount)
                if firstName != nil {
                    speechName = firstName!
                }
            }
            
            setConstraintIdentifierForLabel(currentlyInvisibleLabel, identifierName: speechName)
            currentlyInvisibleLabel.index = speechCount
            currentlyInvisibleLabel.text = speechName
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if labelConstraintsNeedUpdate {
                labelConstraintsNeedUpdate = false
                let oldConstraints = constraints() as [NSLayoutConstraint]
                enumerateLabels(labels, block: { (label, nextLabel) in
                    var xMultiplier = CGFloat(0)
                    var yMultiplier = CGFloat(0)
                    let newConstraints = self.constraintsForLabel(nextLabel, constraints: oldConstraints)
                    let oldConstraints = self.constraintsForLabel(label, constraints: oldConstraints)
                    xMultiplier = newConstraints.xConstraint.multiplier
                    yMultiplier = newConstraints.yConstraint.multiplier
                    
                    let (xConstraint, yConstraint) = NSLayoutConstraint.generateConstraints(label, toItem:self, xMultiplier:xMultiplier , yMultiplier: yMultiplier)
                    NSLayoutConstraint.deactivateConstraints([oldConstraints.xConstraint, oldConstraints.yConstraint])
                    NSLayoutConstraint.activateConstraints([xConstraint, yConstraint])
                    
            })
            makeDataSourceCalls()
        }
    }
    
    func constraintsForLabel(label: TickerLabel, constraints: [NSLayoutConstraint]) -> (xConstraint: NSLayoutConstraint, yConstraint: NSLayoutConstraint) {
        var yConstraint: NSLayoutConstraint? = nil
        var xConstraint: NSLayoutConstraint? = nil
       
        for constraint in constraints {
            if (yConstraint != nil && xConstraint != nil) {
                break
            }
            
            switch constraint.identifier ?? "" {
                case "X constraint for label: \(label.hash)":
                xConstraint = constraint
                case "Y constraint for label: \(label.hash)":
                yConstraint = constraint
                default: print("")
            }
        }
        
        return (xConstraint!, yConstraint!)
    }
    
    func setConstraintIdentifierForLabel(label: TickerLabel, identifierName: String) {
        let (xConstraint, yConstraint) = constraintsForLabel(label, constraints: constraints() as [NSLayoutConstraint])
        xConstraint.identifier = "X constraint for label: \(label.hash)"
        yConstraint.identifier = "Y constraint for label: \(label.hash)"
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
