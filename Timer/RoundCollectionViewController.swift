//
//  RoundCollectionViewController.swift
//  Timer
//
//  Created by EandZ on 3/14/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

let cellReuseIdentifier = "CellReuseIdentifier"
final class RoundCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    static let viewControllers: [ViewController] = {
        let allRounds = Round.allRounds()
        let vcs = allRounds.map {
            ViewController(partialEngine: RoundUIEngine.createEngine($0))
        }
        return vcs
    }()
    
    static let views: [Round: UIView] = { () -> [Round: UIView] in
        let views = RoundCollectionViewController.viewControllers.map { vc -> UIView in
            let view = vc.view.snapshotViewAfterScreenUpdates(true)
            view.bounds.size = CGSize(width: 384, height: 512)
            view.bounds.origin = CGPoint(x: 0, y: 0)
            return view
        }.map { view -> UIView in
            return view.snapshotViewAfterScreenUpdates(true)
        }
        let allRounds = Round.allRounds()
        
        return zip(allRounds, views).reduce([Round: UIView]()) { (dictionary, roundsAndViews) -> [Round: UIView] in
            var dict = dictionary
            let key = roundsAndViews.0
            let value = roundsAndViews.1
            dict.updateValue(value, forKey: key)
            return dict
        }
    }()
    
    let addButton = UIButton(type: .System)
    let collectionView: UICollectionView
    let allRounds = Round.allRounds()
    let draggingHandler: CellDraggingHandler
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 384, height: 512)
        // one vertical scrolling collumn
        flowLayout.minimumInteritemSpacing = 1000
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 100, 0)
//        flowLayout.minimumLineSpacing = 1000
        flowLayout.scrollDirection = .Horizontal
        
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        draggingHandler = CellDraggingHandler(collectionView: self.collectionView)
        collectionView.registerClass(RoundCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        view.addSubview(collectionView)
        constrain(collectionView) { collectionView in
            collectionView.center == collectionView.superview!.center
            collectionView.size == collectionView.superview!.size
        }
        collectionView.backgroundColor = .lightGrayColor()
        
        //FIXME: Refactor this logic into it's own view.
        let rect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let movePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMaxY(rect))
        CGContextMoveToPoint(context, movePoint.x, movePoint.y)
        
        let linePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMinY(rect))
        CGContextAddLineToPoint(context, linePoint.x, linePoint.y)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, 5)
        CGContextStrokePath(context)

        let rightMovePoint = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMidY(rect))
        CGContextMoveToPoint(context, rightMovePoint.x, rightMovePoint.y)
        let pointToMoveTo = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMidY(rect))
        CGContextAddLineToPoint(context, pointToMoveTo.x, pointToMoveTo.y)
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        addButton.setImage(image, forState: .Normal)
        view.addSubview(addButton)
        constrain(addButton) { addButton in
            addButton.centerX == addButton.superview!.centerX * 1.7
            addButton.centerY == addButton.superview!.centerY * 0.3
        }
        addButton.addTarget(self, action: #selector(addRound), forControlEvents: .TouchUpInside)
    }
    
    func addRound() {
        let createRoundViewController = CreateRoundViewController(configuration: DefaultConfiguration())
        presentViewController(createRoundViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRounds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! RoundCollectionViewCell
        cell.draggingHandler = draggingHandler
            let view = RoundCollectionViewController.views[allRounds[indexPath.row]]!
         cell.contentView.addSubview(view)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let viewController = RoundCollectionViewController.viewControllers[indexPath.row]
        viewController.transitioningDelegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Code taken from iOS 7 demos.
        let indexPath = collectionView.indexPathsForSelectedItems()![0]
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        let containerView = transitionContext.containerView()
        let viewControllerFrom = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let viewControllerTo = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromView = viewControllerFrom.view
        let toView = viewControllerTo.view
        let beginFrame = containerView?.convertRect(cell!.bounds, fromView: cell)
        let endFrame = transitionContext.initialFrameForViewController(viewControllerFrom)
        var move: UIView? = nil
        
        if viewControllerTo.isBeingPresented() {
            toView?.frame = endFrame
            move = toView.snapshotViewAfterScreenUpdates(true)
            move?.frame = beginFrame!
            cell?.hidden = true
        } else {
            move = fromView?.snapshotViewAfterScreenUpdates(true)
            move?.frame = fromView!.frame
            fromView?.removeFromSuperview()
            containerView?.addSubview(toView)
        }
        
        containerView?.addSubview(move!)
            
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 500, initialSpringVelocity: 15, options: UIViewAnimationOptions(rawValue: 0), animations: {
                move!.frame = viewControllerTo.isBeingPresented() ? endFrame : beginFrame!
        }, completion: { success in
            if viewControllerTo.isBeingPresented() {
                move?.removeFromSuperview()
                toView?.frame = endFrame
                containerView?.addSubview(toView!)
                transitionContext.completeTransition(true)

            } else {
                cell?.hidden = false
                transitionContext.completeTransition(true)
            }
        })
    }
}
