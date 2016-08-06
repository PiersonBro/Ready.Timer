//
//  DragHandler.swift
//  Din
//
//  Created by E&Z Pierson on 8/18/15.
//  Copyright © 2015 Rez Works. All rights reserved.
//

import UIKit

//FIXME: Change deployment target to iOS 9.
@available(iOS 9.0, *)
public class DragHandler: NSObject, UIDynamicAnimatorDelegate {
    public typealias OrderedLabels = (left: UILabel, right: UILabel, top: UILabel, bottom: UILabel)
    
    private let labels: [UILabel]
    
    private let view: UIView
    let dynamicAnimator: UIDynamicAnimator
    
    private var leftToCenter: UIAttachmentBehavior? = nil
    private var rightToBottom: UIAttachmentBehavior? = nil
    private var bottomToLeft: UIAttachmentBehavior? = nil
    private var centerToRight: UIAttachmentBehavior? = nil
    
    private var panGestureRecognizer: UIPanGestureRecognizer? = nil
    
    private var didShift: Bool? = nil
    
    let positionTracker: PositionTracker
    
    public var delegate: DragHandlerDelegate? = nil
    //FIXME: Is this the correct inital value?
    public var didRotateUsingThisSystem = false
    
    public init(orderedLabels: OrderedLabels) {
        self.labels = [orderedLabels.left, orderedLabels.top, orderedLabels.right, orderedLabels.bottom]
        view = labels.first!.superview!
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        #if DEBUG
            dynamicAnimator.debugEnabled = true
        #endif
        positionTracker = PositionTracker(orderedLabels: orderedLabels)
    }
    
    func configureAttachmentBehaviors() {
        dynamicAnimator.delegate = self
        
        leftToCenter = UIAttachmentBehavior.slidingAttachment(with: positionTracker.leftLabel, attachmentAnchor: positionTracker.leftLabel.center, axisOfTranslation: CGVector(dx: 3, dy: 5))
        rightToBottom = UIAttachmentBehavior.slidingAttachment(with: positionTracker.rightLabel, attachmentAnchor: positionTracker.rightLabel.center, axisOfTranslation: CGVector(dx: -6, dy: -12))
        centerToRight = UIAttachmentBehavior.slidingAttachment(with: positionTracker.topLabel, attachmentAnchor: positionTracker.topLabel.center, axisOfTranslation: CGVector(dx: 5, dy: -5))
        bottomToLeft = UIAttachmentBehavior.slidingAttachment(with: positionTracker.bottomLabel, attachmentAnchor: positionTracker.bottomLabel.center, axisOfTranslation: CGVector(dx: -1, dy: 2))
        dynamicAnimator.addBehavior(leftToCenter!)
        dynamicAnimator.addBehavior(rightToBottom!)
        dynamicAnimator.addBehavior(bottomToLeft!)
        dynamicAnimator.addBehavior(centerToRight!)
    }
    
    // MARK: Public API
    public func activate() {
        if panGestureRecognizer == nil {
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        }

        dynamicAnimator.removeAllBehaviors()
        configureAttachmentBehaviors()
        if view.gestureRecognizers == nil || !view.gestureRecognizers!.contains(panGestureRecognizer!) {
            view.addGestureRecognizer(panGestureRecognizer!)
        }
    }
    
    public func deactivate() {
        dynamicAnimator.removeAllBehaviors()
        view.removeGestureRecognizer(panGestureRecognizer!)
    }
    
    var place: Place? = nil
    var centers: PositionTracker.Centers? = nil
    
    func didDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        let newCenter = gestureRecognizer.location(in: view)
        
        if gestureRecognizer.state == .began {
            centers = captureCenters()
            place = placeForLabel(pointIsNearestToView(newCenter))
        } else if gestureRecognizer.state == .cancelled || gestureRecognizer.state == .ended {
            place = nil
            dynamicAnimator.removeAllBehaviors()
            configureSnapBehaviors()
            didRotateUsingThisSystem = true
        }
        
        guard let place = place else {
            return
        }
        
        let inverter = Inverter(leftToTop: leftToCenter!, topToRight: centerToRight!, rightToBottom: rightToBottom!, bottomToLeft: bottomToLeft!, newCenter: newCenter, place: place)
        inverter.configure()
    }
    
    func captureCenters() -> PositionTracker.Centers {
        return (right: positionTracker.rightLabel.center, left: positionTracker.leftLabel.center, bottom: positionTracker.bottomLabel.center, top: positionTracker.topLabel.center)
    }
    
    var snapBehaviorsActive = false
    
    func configureSnapBehaviors() {
        dynamicAnimator.removeAllBehaviors()
        positionTracker.shiftToPoints(centers!, updatingExternalAnimator: dynamicAnimator, shifted: { didShift = $0 }) {
            self.panGestureRecognizer?.isEnabled = true
            self.snapBehaviorsActive = false
            self.configureAttachmentBehaviors()
        }
        centers = nil
        snapBehaviorsActive = true
    }
    
    func labelsExternallyShifted() {
        positionTracker.pureShift()
        dynamicAnimator.removeAllBehaviors()
        configureAttachmentBehaviors()
    }
    
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if snapBehaviorsActive {
            panGestureRecognizer?.isEnabled = false
            snapBehaviorsActive = false
            animator.removeAllBehaviors()
            if let delegate = delegate {
                delegate.didFinishDrag(didShift!)
            }
        }
    }
    
    func enumerate<T>(_ array: [T], block: (value: T, nextValue: T) -> Void) {
        for i in 0..<array.count {
            let value = array[i]
            let next: T
            let nextIndex = i + 1
            
            if (nextIndex < array.count) {
                next = array[nextIndex]
            } else {
                next = array.first!
            }
            
            block(value: value, nextValue: next)
        }
    }
    
    func pointIsNearestToView(_ point: CGPoint) -> UILabel {
        var closestLabel: UILabel? = nil
        var closestDistance = CGFloat(INT_MAX)
        labels.forEach { label in
            let distance = DragHandler.distanceToRect(label.frame, fromPoint: point)
            if  distance < closestDistance {
                closestDistance = distance
                closestLabel = label
            }
        }
        
        return closestLabel!
    }
    
    static func pointIsNearestToView(_ point: CGPoint, labels: [UILabel]) -> UILabel {
        var closestLabel: UILabel? = nil
        var closestDistance = CGFloat(INT_MAX)
        labels.forEach { label in
            let distance = distanceToRect(label.frame, fromPoint: point)
            if  distance < closestDistance {
                closestDistance = distance
                closestLabel = label
            }
        }
        
        return closestLabel!
    }
    
    func placeForLabel(_ label: UILabel) -> Place {
        switch label {
        case positionTracker.leftLabel:
            return .left
        case positionTracker.rightLabel:
            return .right
        case positionTracker.bottomLabel:
            return .bottom
        case positionTracker.topLabel:
            return .top
        default:
            switch arc4random() % 3 {
            case 0:
                return .left
            case 1:
                return .right
            case 2:
                return .bottom
            case 3:
                return .top
            default:
                fatalError()
            }
        }
    }
    
    private static func distanceToRect(_ rect: CGRect, fromPoint point: CGPoint) -> CGFloat {
        let dx = max(rect.minX - point.x, point.x - rect.maxX, 0)
        let dy = max(rect.minY - point.y, point.y - rect.maxY, 0)
        if dx * dy == 0 {
            return max(dx, dy)
        } else {
            return hypot(dx, dy)
        }
    }
}

public protocol DragHandlerDelegate {
    func didFinishDrag(_ wasShift: Bool)
}

public final class Inverter {
    private let leftToTop: UIAttachmentBehavior
    private let topToRight: UIAttachmentBehavior
    private let rightToBottom: UIAttachmentBehavior
    private let bottomToLeft: UIAttachmentBehavior
    private let newCenter: CGPoint
    private let place: Place
    
    public init(leftToTop: UIAttachmentBehavior, topToRight: UIAttachmentBehavior, rightToBottom: UIAttachmentBehavior, bottomToLeft: UIAttachmentBehavior, newCenter: CGPoint, place: Place) {
        self.leftToTop = leftToTop
        self.topToRight = topToRight
        self.rightToBottom = rightToBottom
        self.bottomToLeft = bottomToLeft
        
        self.newCenter = newCenter
        self.place = place
    }
    
    public func configure() {
        switch place {
        case .left:
            configureForLeftView(newCenter)
        case .top:
            configureForTopView(newCenter)
        case .right:
            configureForRightView(newCenter)
        case .bottom:
            configureForBottomView(newCenter)
        }
    }
    
    private func configureForLeftView(_ newCenter: CGPoint) {
        let topToRightValue = (point: newCenter, attachmentBehavior: topToRight, previousPoint: leftToTop.anchorPoint)
        topToRight.anchorPoint = invertPoint(.topToRight(topToRightValue), pivotLabelColor: .left)
        
        let bottomToLeftValue = (point: newCenter, attachmentBehavior: bottomToLeft, previousPoint: leftToTop.anchorPoint)
        bottomToLeft.anchorPoint = invertPoint(.bottomToLeft(bottomToLeftValue), pivotLabelColor: .left)
        
        let rightToBottomValue = (point: newCenter, attachmentBehavior: rightToBottom, previousPoint: leftToTop.anchorPoint)
        rightToBottom.anchorPoint = invertPoint(.rightToBottom(rightToBottomValue), pivotLabelColor: .left)
        
        leftToTop.anchorPoint = newCenter
    }
    
    private func configureForTopView(_ newCenter: CGPoint) {
        let bottomToLeftValue = (point: newCenter, attachmentBehavior: bottomToLeft, previousPoint: topToRight.anchorPoint)
        bottomToLeft.anchorPoint = invertPoint(.bottomToLeft(bottomToLeftValue), pivotLabelColor: .top)
        
        let leftToTopValue = (point: newCenter, attachmentBehavior: leftToTop, previousPoint: topToRight.anchorPoint)
        leftToTop.anchorPoint = invertPoint(.leftToTop(leftToTopValue), pivotLabelColor: .top)
        
        let rightToBottomValue = (point: newCenter, attachmentBehavior: rightToBottom, previousPoint: topToRight.anchorPoint)
        rightToBottom.anchorPoint = invertPoint(.rightToBottom(rightToBottomValue), pivotLabelColor: .top)
        
        topToRight.anchorPoint = newCenter
    }
    
    private func configureForRightView(_ newCenter: CGPoint) {
        let bottomToLeftValue = (point: newCenter, attachmentBehavior: bottomToLeft, previousPoint: rightToBottom.anchorPoint)
        bottomToLeft.anchorPoint = invertPoint(.bottomToLeft(bottomToLeftValue), pivotLabelColor: .right)
        
        let leftToTopValue = (point: newCenter, attachmentBehavior: leftToTop, previousPoint: rightToBottom.anchorPoint)
        leftToTop.anchorPoint = invertPoint(.leftToTop(leftToTopValue), pivotLabelColor: .right)
        
        let topToRightValue = (point: newCenter, attachmentBehavior: topToRight, previousPoint: rightToBottom.anchorPoint)
        topToRight.anchorPoint = invertPoint(.topToRight(topToRightValue), pivotLabelColor: .right)
        
        rightToBottom.anchorPoint = newCenter
    }
    
    private func configureForBottomView(_ newCenter: CGPoint) {
        let leftToTopValue = (point: newCenter, attachmentBehavior: leftToTop, previousPoint: bottomToLeft.anchorPoint)
        leftToTop.anchorPoint = invertPoint(.leftToTop(leftToTopValue), pivotLabelColor: .bottom)
        
        let topToRightValue = (point: newCenter, attachmentBehavior: topToRight, previousPoint: bottomToLeft.anchorPoint)
        topToRight.anchorPoint = invertPoint(.topToRight(topToRightValue), pivotLabelColor: .bottom)
        
        let rightToBottomValue = (point: newCenter, attachmentBehavior: rightToBottom, previousPoint: bottomToLeft.anchorPoint)
        rightToBottom.anchorPoint = invertPoint(.rightToBottom(rightToBottomValue), pivotLabelColor: .bottom)
        
        bottomToLeft.anchorPoint = newCenter
    }
    
    //FIXME: Refactor this into a struct, since it's pure calculation and fits the idea of a value type perfectly
    private func invertPoint(_ direction: Direction, pivotLabelColor: Place) -> CGPoint {
        let point = direction.value.point
        let previousPoint = direction.value.previousPoint
        let pointsToAdd: CGFloat
        
        if point.x > previousPoint.x && point.y < previousPoint.y  {
            pointsToAdd = 4
        } else if point.x < previousPoint.x && point.y > previousPoint.y {
            pointsToAdd = 4
        } else {
            pointsToAdd = 0
        }
        
        let diff = CGPoint(x: previousPoint.x - point.x + pointsToAdd, y: previousPoint.y - point.y + pointsToAdd)
        
        switch pivotLabelColor {
        case .top:
            return invertPointFromTopView(diff, direction: direction)
        case .right:
            return invertPointFromRightView(diff, direction: direction)
        case .bottom:
            return invertPointFromBottomView(diff, direction: direction)
        case .left:
            return invertPointFromLeftView(diff, direction: direction)
        }
    }
    
    private func invertPointFromTopView(_ diff: CGPoint, direction: Direction) -> CGPoint {
        switch direction {
        case let .topToRight(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .leftToTop(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .bottomToLeft(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .rightToBottom(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        }
    }
    
    private func invertPointFromRightView(_ diff: CGPoint, direction: Direction) -> CGPoint {
        switch direction {
        case let .topToRight(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .leftToTop(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .bottomToLeft(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .rightToBottom(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        }
    }
    
    private func invertPointFromBottomView(_ diff: CGPoint, direction: Direction) -> CGPoint {
        switch direction {
        case let .topToRight(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .leftToTop(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .bottomToLeft(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .rightToBottom(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        }
    }
    
    private func invertPointFromLeftView(_ diff: CGPoint, direction: Direction) -> CGPoint {
        switch direction {
        case let .topToRight(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        case let .leftToTop(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x - diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .bottomToLeft(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y - diff.y)
        case let .rightToBottom(_, attachmentBehavior, _):
            return CGPoint(x: attachmentBehavior.anchorPoint.x + diff.x, y: attachmentBehavior.anchorPoint.y + diff.y)
        }
    }
}

typealias DirectionValue = (point: CGPoint, attachmentBehavior: UIAttachmentBehavior, previousPoint: CGPoint)

enum Direction {
    case topToRight(DirectionValue)
    case leftToTop(DirectionValue)
    case bottomToLeft(DirectionValue)
    case rightToBottom(DirectionValue)
    
    var value: DirectionValue {
        switch self {
        case let .topToRight(directionValue):
            return directionValue
        case let .leftToTop(directionValue):
            return directionValue
        case let .bottomToLeft(directionValue):
            return directionValue
        case let .rightToBottom(directionValue):
            return directionValue
        }
    }
}

public enum Place {
    case top
    case right
    case bottom
    case left
}


// This class is responsible for returning an accurate leftLabel rightLabel, etc.
// It must also make sure that those labels are in the right place after shift is called.
// If a label ends up in a confused state, the positionTracker will reset it to it's proper place.
class PositionTracker: NSObject, UIDynamicAnimatorDelegate {
    typealias Centers = (right: CGPoint, left: CGPoint, bottom: CGPoint, top: CGPoint)
    
    var leftLabel: UILabel
    var rightLabel: UILabel
    var topLabel: UILabel
    var bottomLabel: UILabel
    
    let labels: [UILabel]
    
    let dynamicAnimator: UIDynamicAnimator
    var externalAnimator: UIDynamicAnimator? = nil
    var callback: (() -> ())? = nil
    
    // `labels` -- The four labels that make up the PositionTracker
    // `centers` -- The locations where the labels should be at the end of animation.
    init(orderedLabels: DragHandler.OrderedLabels) {
        leftLabel = orderedLabels.left
        rightLabel = orderedLabels.right
        topLabel = orderedLabels.top
        bottomLabel = orderedLabels.bottom
        labels = [leftLabel, topLabel, rightLabel, bottomLabel]
        dynamicAnimator = UIDynamicAnimator(referenceView: topLabel.superview!)
        super.init()
        dynamicAnimator.delegate = self
    }

    func shiftToPoints(_ centers: Centers, updatingExternalAnimator: UIDynamicAnimator?, shifted: @noescape (shifted: Bool) -> (), callback: () -> ()) {
        externalAnimator = updatingExternalAnimator
        self.callback = callback
        
        let shouldCleanUpAfterFailure = [centers.right, centers.left, centers.top, centers.bottom].map { point -> [Bool] in
            //FIXME: This shouldn't be needed.                                      --
            let result = [leftLabel, rightLabel, topLabel, bottomLabel].map { (label: UILabel) -> Bool in
                CGPoint(x: ceil(point.x), y: ceil(point.y)) == CGPoint(x: ceil(label.center.x), y: ceil(label.center.y))
            }
            return result
            }.map { truthTable -> Bool in
                let value = truthTable.filter { $0 == true }.first
                return value ?? false
            }.filter { bool in
                return bool == false
            }.first
       
        let shouldShift: Bool
        if shouldCleanUpAfterFailure != nil {
            shouldShift = cleanUpAfterFailure(centers)
        } else {
            shouldShift = true
        }
        
        if shouldShift {
            pureShift()
        }
        
        shifted(shifted: shouldShift)
        
        if shouldCleanUpAfterFailure == nil {
            callback()
        }
    }
    
    func pureShift() {
        let oldLeftLabel = leftLabel
        let oldRightLabel = rightLabel
        let oldTopLabel = topLabel
        let oldBottomLabel = bottomLabel
        
        leftLabel = oldBottomLabel
        topLabel = oldLeftLabel
        rightLabel = oldTopLabel
        bottomLabel = oldRightLabel
    }
    
    func cleanUpAfterFailure(_ centers: Centers) -> Bool {
        let leftIsClosestToTop = DragHandler.pointIsNearestToView(centers.top, labels: labels) == leftLabel
        let topIsClosestToRight = DragHandler.pointIsNearestToView(centers.right, labels: labels) == topLabel
        let rightIsClosestToBottom = DragHandler.pointIsNearestToView(centers.bottom, labels: labels) == rightLabel
        let bottomIsClosestToLeft = DragHandler.pointIsNearestToView(centers.left, labels: labels) == bottomLabel
        
        if !leftIsClosestToTop && !topIsClosestToRight && !rightIsClosestToBottom && !bottomIsClosestToLeft {
            let leftToLeft = UISnapBehavior(item: leftLabel, snapTo: centers.left)
            let rightToRight = UISnapBehavior(item: rightLabel, snapTo: centers.right)
            let topToTop = UISnapBehavior(item: topLabel, snapTo: centers.top)
            let bottomToBottom = UISnapBehavior(item: bottomLabel, snapTo: centers.bottom)
            
            dynamicAnimator.addBehavior(leftToLeft)
            dynamicAnimator.addBehavior(rightToRight)
            dynamicAnimator.addBehavior(topToTop)
            dynamicAnimator.addBehavior(bottomToBottom)
            return false
        }
        
        let leftToTop = UISnapBehavior(item: leftLabel, snapTo: centers.top)
        let topToRight = UISnapBehavior(item: topLabel, snapTo: centers.right)
        let rightToBottom = UISnapBehavior(item: rightLabel, snapTo: centers.bottom)
        let bottomToLeft = UISnapBehavior(item: bottomLabel, snapTo: centers.left)
        
        dynamicAnimator.addBehavior(leftToTop)
        dynamicAnimator.addBehavior(topToRight)
        dynamicAnimator.addBehavior(rightToBottom)
        dynamicAnimator.addBehavior(bottomToLeft)
        return true
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        externalAnimator?.updateItem(usingCurrentState: leftLabel)
        externalAnimator?.updateItem(usingCurrentState: rightLabel)
        externalAnimator?.updateItem(usingCurrentState: topLabel)
        externalAnimator?.updateItem(usingCurrentState: bottomLabel)
        callback!()
    }
}
