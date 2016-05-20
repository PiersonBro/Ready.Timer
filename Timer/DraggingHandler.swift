//
//  DraggingHandler.swift
//  RolodexCollectionView
//
//  Created by E&Z Pierson on 6/7/15.
//  Copyright (c) 2015 Rez Works. All rights reserved.
//

import UIKit

public class CellDraggingHandler: NSObject, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {
    let collectionView: UICollectionView
    let dynamicAnimator: UIDynamicAnimator
    
    var currentAttachmentBehavior: UIAttachmentBehavior? = nil
    var currentSnapBehavior: UISnapBehavior? = nil
    var currentGestureRecognizer: UIGestureRecognizer? = nil
    var successSnapBehavior: UISnapBehavior? = nil
    // This is so that when `dynamicAnimatorDidPause` is called we can intelligently dispose of resources.
    var gestureRecognizerState: UIGestureRecognizerState? = nil
    var currentIndexPath: NSIndexPath? = nil
    var delegate: CellDraggingDelegate? = nil
    var deleteOccured: Bool = false
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        dynamicAnimator = UIDynamicAnimator(referenceView: collectionView)
        super.init()
        dynamicAnimator.delegate = self
    }
    
    public func cellWasDragged(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer != currentGestureRecognizer && currentGestureRecognizer != nil {
            return
        } else {
            currentGestureRecognizer = gestureRecognizer
        }
        
        let location = gestureRecognizer.locationInView(collectionView)
        gestureRecognizerState = gestureRecognizer.state
        
        switch gestureRecognizer.state {
        case .Began:
            
            let indexPath = collectionView.indexPathForItemAtPoint(location)
        
            collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: [.CenteredVertically, .CenteredHorizontally])
            if let indexPath = indexPath {
                currentIndexPath = indexPath
                let cell = collectionView.cellForItemAtIndexPath(indexPath)! /* as! RolodexCollectionViewCell */
                
                currentAttachmentBehavior = UIAttachmentBehavior.slidingAttachmentWithItem(cell, attachmentAnchor: cell.center, axisOfTranslation: CGVector(dx: 1, dy: 0))
                dynamicAnimator.addBehavior(currentAttachmentBehavior!)
                currentSnapBehavior = UISnapBehavior(item: cell, snapToPoint: cell.center)
                let offScreenPoint = CGPoint(x: cell.center.x, y: cell.center.y - 2000)
                successSnapBehavior = UISnapBehavior(item: cell, snapToPoint: offScreenPoint)
            }
        case .Changed:
            currentAttachmentBehavior?.anchorPoint = location
        case .Ended:
            if let currentSnapBehavior = currentSnapBehavior, let currentAttachmentBehavior = currentAttachmentBehavior, let successSnapBehavior = successSnapBehavior {
                if location.y <= 200 {
                    delegate!.delete(currentIndexPath!) { shouldDelete in
                        if shouldDelete {
                            self.dynamicAnimator.addBehavior(successSnapBehavior)
                            self.deleteOccured = true
                        } else {
                            self.dynamicAnimator.addBehavior(currentSnapBehavior)
                            self.deleteOccured = false
                        }
                    }
                } else {
                    dynamicAnimator.addBehavior(currentSnapBehavior)
                }
                
                dynamicAnimator.removeBehavior(currentAttachmentBehavior)
            }
        case .Cancelled:
            gestureRecognizer.enabled = true
            
        default:
            break
        }
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translation = (gestureRecognizer as! UIPanGestureRecognizer).translationInView(collectionView)
        let result = translation.x * translation.x > translation.y * translation.y
        return !result
    }
    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        if gestureRecognizerState == .Ended || gestureRecognizerState == .Cancelled {
            cleanUpState()
            if deleteOccured {
                delegate!.deleteDidOccur()
                deleteOccured = false
            }
            
        }
    }
    
    private func cleanUpState() {
        dynamicAnimator.removeAllBehaviors()
        currentAttachmentBehavior = nil
        currentGestureRecognizer = nil
        currentSnapBehavior = nil
        successSnapBehavior = nil
        currentIndexPath = nil
    }
}

protocol CellDraggingDelegate {
    func delete(indexPath: NSIndexPath, completion: (shouldDelete: Bool) -> ())
    func deleteDidOccur()
}

