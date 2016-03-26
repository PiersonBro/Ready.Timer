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
                
                if location.y <= 100 {
                    let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete x?", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { action in
                        self.dynamicAnimator.addBehavior(successSnapBehavior)
                        //FIXME: Figure out how to delete.
                        self.collectionView.performBatchUpdates({
                            self.collectionView.deleteItemsAtIndexPaths([self.currentIndexPath!])
                            self.collectionView.reloadSections(NSIndexSet(index: 0))
                        }, completion: nil)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                        self.dynamicAnimator.addBehavior(currentSnapBehavior)
                    }))
                    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    
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
