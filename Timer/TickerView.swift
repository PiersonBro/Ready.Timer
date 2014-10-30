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

private typealias PositionTuple = (xMultiplier: Float, yMultiplier: Float)
private enum Position {
    case Center(PositionTuple)
    case Right(PositionTuple)
    case Left(PositionTuple)
    case Bottom(PositionTuple)

    // Convenience access to the associated values of the enum.
    var positionTuple: PositionTuple {
        switch (self) {
            case .Center(let xMultiplier, let yMultiplier):
                return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
            case .Right(let xMultiplier, let yMultiplier):
                return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
            case .Left(let xMultiplier, let yMultiplier):
                return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
            case .Bottom(let xMultiplier, let yMultiplier):
                return (xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        }
    }
    
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

private extension Position {
    static let staticCenter: Position = Position.Center((xMultiplier: 1, yMultiplier: 0.5))
    static let staticRight: Position = Position.Right((xMultiplier: 1.5, yMultiplier: 0.7))
    static let staticLeft: Position = Position.Left((xMultiplier: 0.5, yMultiplier: 0.7))
    static let staticBottom: Position = Position.Bottom((xMultiplier: 1, yMultiplier: 1.5))

}

class TickerView: UIView {
    // Subviews
    private let bottommostLabel: TickerLabel
    private let rightmostLabel: TickerLabel
    private let topmostLabel: TickerLabel
    private let leftmostLabel: TickerLabel

    private let leftDivider: UIView
    private let rightDivider: UIView
    
    private var currentlyInvisibleLabel: TickerLabel {
        var invisibleLabel: TickerLabel? = nil
            let mask = layer.mask as CAShapeLayer
            let bezierPath: UIBezierPath = UIBezierPath(CGPath: mask.path)
            for label in labels {
                if !bezierPath.containsPoint(label.center) {
                    invisibleLabel = label
                    break
                }
            }
            
            return invisibleLabel!
    }
    
    private var labelConstraintsNeedUpdate: Bool = false

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
        
        leftDivider = UIView(frame: CGRect())
        leftDivider.backgroundColor = UIColor.redColor()
        rightDivider = UIView(frame: CGRect())
        rightDivider.backgroundColor = UIColor.blueColor()
        
        animator = UIDynamicAnimator()
        labels = [leftmostLabel, topmostLabel, rightmostLabel, bottommostLabel]
        speechCount = 0
        self.dataSource = dataSource
        self.delegate = delegate
        speechIndexToUpdate = 0;
        super.init(frame: frame)
        
        topmostLabel = configureLabel(topmostLabel, text: self.dataSource.stringForIndex(speechCount) ?? "E", positions: Position.staticCenter)
        self.delegate.tickerViewDidRotateStringAtIndexToCenterPosition(speechCount)
        topmostLabel.index = speechCount

        leftmostLabel = configureLabel(leftmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions: Position.staticLeft)
        leftmostLabel.index = speechCount
        bottommostLabel = configureLabel(bottommostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions: Position.staticBottom)
        bottommostLabel.index = speechCount
        rightmostLabel = configureLabel(rightmostLabel, text: self.dataSource.stringForIndex(++speechCount) ?? "E", positions:Position.staticRight)
        rightmostLabel.index = speechCount
       
        addSubview(leftDivider)
        layout(leftDivider, self) { (leftDivider, view) in
            leftDivider.centerX == view.centerX * 0.7
            leftDivider.centerY == view.centerY
            leftDivider.height == view.height
            leftDivider.width == view.width / 64
        }
        
        addSubview(rightDivider)
        layout(rightDivider, self) { (rightDivider, view) in
            rightDivider.centerX == view.centerX  * 1.35
            rightDivider.centerY == view.centerY
            rightDivider.height == view.height
            rightDivider.width == view.width / 64
        }
        
        animator = UIDynamicAnimator(referenceView: self)
        layer.masksToBounds = true
        backgroundColor =  UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        // FIXME: This leads to janky rotation animations, and should be fixed before release.
        contentMode = .Redraw
    }

    private func configureLabel(label: TickerLabel, text: String, positions: Position) -> TickerLabel {
        label.font = UIFont.systemFontOfSize(60)
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.cyanColor()
        label.text = text
        
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(label)
        layoutLabel(label, position: positions)

        return label
    }
    
   private func layoutLabel(label: TickerLabel, position: Position) {
        var xConstraint: NSLayoutConstraint? = nil
        var yConstraint: NSLayoutConstraint? = nil
        var widthConstraint: NSLayoutConstraint? = nil
    
        layout([label, self, rightDivider, leftDivider]) { (layoutProxies) in
            let label = layoutProxies[0]
            let view = layoutProxies[1]
            let rightDivider = layoutProxies[2]
            let leftDivider = layoutProxies[3]
            
            xConstraint = label.centerX == view.centerX * position.positionTuple.xMultiplier
            yConstraint = label.centerY == view.centerY * position.positionTuple.yMultiplier
        }
    
        xConstraint?.identifier = "X constraint for label: \(label.hash)"
        yConstraint?.identifier = "Y constraint for label: \(label.hash)"
    }
    
    override func drawRect(rect: CGRect) {
        let layers = self.layer.sublayers as [CALayer]
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
        for label in labels  {
            let constraints = self.positioningConstraintsForLabel(label, constraints: self.constraints() as [NSLayoutConstraint])
            let result = Position.positionForMultipliers(constraints.xConstraint.multiplier, yMultiplier: constraints.yConstraint.multiplier)
            
            if let result = result {
                switch (result) {
                    case .Bottom(let xMultiplier, let yMultiplier):
                        self.delegate.tickerViewDidRotateStringAtIndexToCenterPosition(label.index)
                    case .Right(let xMultiplier, let yMultiplier):
                        self.delegate.tickerViewDidRotateStringAtIndexToRightPosition(label.index)
                    default:
                        break
                }
            } else {
                println(constraints.xConstraint.multiplier)
                println(constraints.yConstraint.multiplier)
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
            
            currentlyInvisibleLabel.index = speechCount
            currentlyInvisibleLabel.text = speechName
        }
    }
    override func updateConstraints() {
        if labelConstraintsNeedUpdate {
                labelConstraintsNeedUpdate = false
                let unmodifiedConstraints = constraints() as [NSLayoutConstraint]
                enumerateLabels(labels, block: { (label, nextLabel) in
                    let oldConstraints = self.positioningConstraintsForLabel(label, constraints: unmodifiedConstraints)
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
            let identifierNSString: NSString = constraint.identifier ?? "" as NSString
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
