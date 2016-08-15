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
    static let staticCenter: Position = Position.center((xMultiplier: 1, yMultiplier: 0.5))
    static let staticRight: Position = Position.right((xMultiplier: 1.5, yMultiplier: 0.8))
    static let staticLeft: Position = Position.left((xMultiplier: 0.5, yMultiplier: 0.8))
    static let staticBottom: Position = Position.bottom((xMultiplier: 1, yMultiplier: 1.5))
    
    static func positionForMultipliers(_ xMultiplier: CGFloat, yMultiplier: CGFloat) -> Position? {
        return positionForMultipliers(Float(xMultiplier), yMultiplier: Float(yMultiplier))
    }
    
    static func positionForMultipliers(_ xMultiplier: Float, yMultiplier: Float) -> Position? {
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

class TickerView: UIView, UIDynamicAnimatorDelegate, DragHandlerDelegate {
    // Subviews
    private var bottommostLabel: TickerLabel
    private var rightmostLabel: TickerLabel
    private var topmostLabel: TickerLabel
    private var leftmostLabel: TickerLabel
    
    private let leftDivider: UIView
    private let rightDivider: UIView
    private let leftEdgeDivider: UIView
    private let rightEdgeDivider: UIView
    
    private var labelConstraintsNeedUpdate: Bool = false {
        didSet {
            if labelConstraintsNeedUpdate == true {
                setNeedsUpdateConstraints()
            }
        }
    }

    private var speechCount: Int
    
    // Strongly held animator objects
    private var animator: UIDynamicAnimator
    private var labels: [TickerLabel]
    
    var dragHandler: DragHandler? = nil
    var machineRotated = false
    
    let dataSource: TickerViewDataSource
    var accentColor: UIColor = .cyan {
        didSet {
            labels.forEach {$0.textColor = accentColor}
            removeLines()
            addLines(bounds)
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("Initializer Not Supported")
    }

    override init(frame: CGRect) {
        fatalError("Initializer Not Supported")
    }
    
    init(dataSource: TickerViewDataSource) {
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
        super.init(frame: CGRect())

        addSubview(leftDivider)
        constrain(leftDivider, self) { (leftDivider, view) in
            leftDivider.centerX == view.centerX * 0.6
            leftDivider.centerY == view.centerY
            leftDivider.height == view.height
            leftDivider.width == view.width / 64
        }
        
        addSubview(rightDivider)
        constrain(rightDivider, self) { (rightDivider, view) in
            rightDivider.centerX == view.centerX * 1.40
            rightDivider.centerY == view.centerY
            rightDivider.height == view.height
            rightDivider.width == view.width / 64
        }
        
        addSubview(leftEdgeDivider)
        constrain(leftEdgeDivider, self) { (leftEdgeDivider, view) in
            leftEdgeDivider.centerX == view.centerX * 0.1
            leftEdgeDivider.centerY == view.centerY
            leftEdgeDivider.height == view.height
            leftEdgeDivider.width == view.width / 64
        }
        
        addSubview(rightEdgeDivider)
        constrain(rightEdgeDivider, self) { (rightEdgeDivider, view) in
            rightEdgeDivider.centerX == view.centerX * 1.9
            rightEdgeDivider.centerY == view.centerY
            rightEdgeDivider.height == view.height
            rightEdgeDivider.width == view.width / 64
        }
        

        setupInitialLabelState()
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        layer.masksToBounds = true
        // FIXME: This leads to janky rotation animations, and should be fixed before release.
        contentMode = .redraw
        #if DEBUG
        animator.debugEnabled = true
        #endif
    }
    
    func setupInitialLabelState() {
        topmostLabel = configureLabel(topmostLabel, text: dataSource.stringForIndex(speechCount) ?? "E", positions: Position.staticCenter)
        topmostLabel.index = speechCount
        
        speechCount = (speechCount + 1)
        leftmostLabel = configureLabel(leftmostLabel, text: dataSource.stringForIndex(speechCount) ?? "E", positions: Position.staticLeft)
        leftmostLabel.index = speechCount
        
        speechCount = (speechCount + 1)
        bottommostLabel = configureLabel(bottommostLabel, text: dataSource.stringForIndex(speechCount) ?? "E", positions: Position.staticBottom)
        bottommostLabel.index = speechCount
        
        speechCount = (speechCount + 1)
        rightmostLabel = configureLabel(rightmostLabel, text: dataSource.stringForIndex(speechCount) ?? "E", positions:Position.staticRight)
        rightmostLabel.index = speechCount
    }
    
    override func tintColorDidChange() {
        backgroundColor = superview?.tintColor
    }
    
    deinit {
        dragHandler?.deactivate()
    }
    
    private func configureLabel(_ label: TickerLabel, text: String, positions: Position) -> TickerLabel {
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = accentColor
        label.text = text
        
        addSubview(label)
        layoutLabel(label, position: positions)

        return label
    }
    
   private func layoutLabel(_ label: TickerLabel, position: Position) {
        var xConstraint: NSLayoutConstraint? = nil
        var yConstraint: NSLayoutConstraint? = nil
        var leftConstraint: NSLayoutConstraint? = nil
        var rightConstraint: NSLayoutConstraint? = nil
    
        constrain([label, rightDivider, leftDivider, rightEdgeDivider, leftEdgeDivider]) { (layoutProxies) in
            let label = layoutProxies[0]
            let rightDivider = layoutProxies[1]
            let leftDivider = layoutProxies[2]
            let rightEdgeDivider = layoutProxies[3]
            let leftEdgeDivider = layoutProxies[4]
            
            xConstraint = (label.centerX == label.superview!.centerX * CGFloat(position.positionTuple.xMultiplier)) ~ 750
            yConstraint = label.centerY == label.superview!.centerY * CGFloat(position.positionTuple.yMultiplier)
            
            switch position {
            case .center:
                leftConstraint = label.left >= leftDivider.right
                rightConstraint = label.right <= rightDivider.left
            case .bottom:
                leftConstraint = label.left <= leftDivider.right
                rightConstraint = label.right <= rightDivider.left
            case .right:
                leftConstraint = label.left == rightDivider.right
                rightConstraint = label.right == rightEdgeDivider.right
            case .left:
                leftConstraint = label.left == leftEdgeDivider.left
                rightConstraint = label.right == leftDivider.left
            }
        }
    
        xConstraint?.identifier = "X constraint for label: \(label.hash)"
        yConstraint?.identifier = "Y constraint for label: \(label.hash)"
        leftConstraint?.identifier = "Left Constraint for label: \(label.hash)"
        rightConstraint?.identifier = "Right Constraint for label: \(label.hash)"
    }
    
    override func draw(_ rect: CGRect) {
        removeLines()
        
        let mask = CAShapeLayer()
        mask.frame = bounds;
        let point = CGPoint(x: rect.midX, y: rect.midY)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: point)
        bezierPath.addArc(withCenter: point, radius: rect.size.width / 2, startAngle:CGFloat(M_PI), endAngle: CGFloat(M_PI) * 2, clockwise: true)
        mask.path = bezierPath.cgPath
        layer.mask = mask
        
        addLines(rect)
        
        if dragHandler == nil {
            dragHandler = DragHandler(orderedLabels: (left: leftmostLabel, right: rightmostLabel, top: topmostLabel, bottom: bottommostLabel))
        }
        
        dragHandler?.delegate = self
        
        dragHandler?.activate()
    }
    
    func addLines(_ rect: CGRect) {
        let leftLineShapeLayer = CAShapeLayer()
        leftLineShapeLayer.name = "leftLineShapeLayer"
        let leftLinePath = UIBezierPath()
        leftLinePath.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        leftLinePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        leftLineShapeLayer.path = leftLinePath.cgPath
        leftLineShapeLayer.strokeColor = accentColor.cgColor
        leftLineShapeLayer.lineWidth = 5
        layer.addSublayer(leftLineShapeLayer)
        
        let rightLineShapeLayer = CAShapeLayer()
        rightLineShapeLayer.name = "rightLineShapeLayer"
        let rightLinePath = UIBezierPath()
        rightLinePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        rightLinePath.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        rightLinePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        rightLineShapeLayer.path = rightLinePath.cgPath
        rightLineShapeLayer.strokeColor = accentColor.cgColor
        rightLineShapeLayer.lineWidth = 5
        layer.addSublayer(rightLineShapeLayer)
    }
    
    private func removeLines() {
        let layers = self.layer.sublayers!
        for subLayer in layers where subLayer.name != nil {
            switch subLayer.name! {
                case "leftLineShapeLayer":
                    subLayer.removeFromSuperlayer()
                case "rightLineShapeLayer":
                    subLayer.removeFromSuperlayer()
                default: break
            }
        }
    }
    
    func rotateToNextSegment() {
        rotate(true)
    }
    
    func rotateToPreviousSegment() {
        rotate(false)
    }
    
    func reset() {
        speechCount = 0
        labels.forEach { $0.removeFromSuperview() }
        leftmostLabel = TickerLabel(frame: CGRect())
        rightmostLabel = TickerLabel(frame: CGRect())
        topmostLabel = TickerLabel(frame: CGRect())
        bottommostLabel = TickerLabel(frame: CGRect())
        
        labels = [leftmostLabel, topmostLabel, rightmostLabel, bottommostLabel]
        setupInitialLabelState()
        addLines(bounds)
        dragHandler?.deactivate()
        dragHandler = DragHandler(orderedLabels: (left: leftmostLabel, right: rightmostLabel, top: topmostLabel, bottom: bottommostLabel))
        
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.dragHandler?.delegate = self
            self.dragHandler?.activate()
        }
    }
    
    private func rotate(_ ascending: Bool) {
        let labelsToEnumerate = ascending ? labels : labels.reversed()
        animator.removeAllBehaviors()
        
        enumerate(labelsToEnumerate) { (label, nextLabel) in
            label.snapBehavior!.snapPoint = nextLabel.center
        }
        
        for label in labels {
            animator.addBehavior(label.snapBehavior!)
        }
        
        let item = UIDynamicItemBehavior(items: labels)
        item.resistance = 150
        animator.addBehavior(item)
        labelConstraintsNeedUpdate = true
        machineRotated = true
    }
    
    //MARK: DragHandler Delegate
    func didFinishDrag(_ wasShift: Bool) {
        if wasShift {
            labelConstraintsNeedUpdate = true
        }
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        if machineRotated {
            dragHandler!.labelsExternallyShifted()
            machineRotated = false
        }
    }
    
    func enumerate<T>(_ array: [T], block: (_ value: T, _ nextValue: T) -> Void) {
        for i in 0..<array.count {
            let value = array[i]
            let next: T
            let nextIndex = i + 1
           
            if (nextIndex < array.count) {
                next = array[nextIndex]
            } else {
                next = array.first!
            }

            block(value, next)
        }
    }
    
    var finalSpeechIsAtCenter = false
    
    func makeDataSourceCalls() {
        let centerLabel = labelForPosition(.staticCenter)
        let rightLabel = labelForPosition(.staticRight)
        let leftLabel = labelForPosition(.staticLeft)
        let bottomLabel = labelForPosition(.staticBottom)
        
        if finalSpeechIsAtCenter {
            dataSource.tickerViewDidRotateStringAtIndexToCenterPosition(centerLabel.index, wasDragged: dragHandler?.didRotateUsingThisSystem ?? false, wasLast: true)
            removeLines()
            rightLabel.isHidden = true
            bottomLabel.isHidden = true
            leftLabel.isHidden = true
            
            finalSpeechIsAtCenter = false
            return
        }
        
        dataSource.tickerViewDidRotateStringAtIndexToCenterPosition(centerLabel.index, wasDragged: dragHandler?.didRotateUsingThisSystem ?? false, wasLast: false)
    
        if dragHandler?.didRotateUsingThisSystem == true {
            dragHandler?.didRotateUsingThisSystem = false
        }
    
        rightLabel.consumed = true
        if (bottomLabel.consumed) {
            speechCount = (speechCount + 1)
            let optionalSpeechName = dataSource.stringForIndex(speechCount)
            let speechName: String
            
            if let name = optionalSpeechName {
                speechName = name
                bottomLabel.index = speechCount
                bottomLabel.text = speechName
            } else {
                finalSpeechIsAtCenter = true
            }
        }
    }

    func labelForPosition(_ positionToFind: Position) -> TickerLabel {
        for label in labels  {
            let constraints = positioningConstraintsForLabel(label, constraints: self.constraints)
            let position = Position.positionForMultipliers(constraints.xConstraint.multiplier, yMultiplier: constraints.yConstraint.multiplier)
            
            if let position = position, position == positionToFind  {
                return label
            }
        }
        fatalError("Could not find label for position: \(positionToFind)")
    }
    
    override func updateConstraints() {
        if labelConstraintsNeedUpdate {
            labelConstraintsNeedUpdate = false
            let unmodifiedConstraints = constraints
            enumerate(labels, block: { (label, nextLabel) in
                let newConstraints = self.positioningConstraintsForLabel(nextLabel, constraints: unmodifiedConstraints)
                let xMultiplier = newConstraints.xConstraint.multiplier
                let yMultiplier = newConstraints.yConstraint.multiplier
                let newPosition = Position.positionForMultipliers(Float(xMultiplier), yMultiplier: Float(yMultiplier))
                
                NSLayoutConstraint.deactivate(self.constraintsForLabel(label, superviewConstraints: unmodifiedConstraints))
                self.layoutLabel(label, position:newPosition!)
            })
            makeDataSourceCalls()
        }
        
        super.updateConstraints()
    }
    
    func constraintsForLabel(_ label: TickerLabel, superviewConstraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        var labelConstraints = [NSLayoutConstraint]()
        for constraint in superviewConstraints {
            let identifier = constraint.identifier ?? ""
            if (identifier.contains(label.hash.description)) {
                labelConstraints.append(constraint)
            }
        }
        return labelConstraints
    }
        
    func positioningConstraintsForLabel(_ label: TickerLabel, constraints: [NSLayoutConstraint]) -> (xConstraint: NSLayoutConstraint, yConstraint: NSLayoutConstraint) {
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
    func stringForIndex(_ index: Int) -> String?
    func tickerViewDidRotateStringAtIndexToCenterPosition(_ index: Int, wasDragged: Bool, wasLast: Bool)
}
