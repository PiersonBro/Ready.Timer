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
    var currentIndexPath: IndexPath? = nil
    var delegate: CellDraggingDelegate? = nil
    var deleteOccured: Bool = false
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        dynamicAnimator = UIDynamicAnimator(referenceView: collectionView)
        super.init()
        dynamicAnimator.delegate = self
    }
    
    public func cellWasDragged(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer != currentGestureRecognizer && currentGestureRecognizer != nil {
            return
        } else {
            currentGestureRecognizer = gestureRecognizer
        }
        
        let location = gestureRecognizer.location(in: collectionView)
        gestureRecognizerState = gestureRecognizer.state
        
        switch gestureRecognizer.state {
        case .began:
            
            let indexPath = collectionView.indexPathForItem(at: location)
        
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.centeredVertically, .centeredHorizontally])
            if let indexPath = indexPath {
                currentIndexPath = indexPath
                let cell = collectionView.cellForItem(at: indexPath)! /* as! RolodexCollectionViewCell */
                
                currentAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: cell, attachmentAnchor: cell.center, axisOfTranslation: CGVector(dx: 1, dy: 0))
                dynamicAnimator.addBehavior(currentAttachmentBehavior!)
                currentSnapBehavior = UISnapBehavior(item: cell, snapTo: cell.center)
                let offScreenPoint = CGPoint(x: cell.center.x, y: cell.center.y - 2000)
                successSnapBehavior = UISnapBehavior(item: cell, snapTo: offScreenPoint)
            }
        case .changed:
            currentAttachmentBehavior?.anchorPoint = location
        case .ended:
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
        case .cancelled:
            gestureRecognizer.isEnabled = true
            
        default:
            break
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: collectionView)
        let result = translation.x * translation.x > translation.y * translation.y
        return !result
    }
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if gestureRecognizerState == .ended || gestureRecognizerState == .cancelled {
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
    func delete(_ indexPath: IndexPath, completion: @escaping (_ shouldDelete: Bool) -> ())
    func deleteDidOccur()
}

