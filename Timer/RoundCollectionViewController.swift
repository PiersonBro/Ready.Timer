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
final class RoundCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, CellDraggingDelegate {
    let viewProducer = ViewProducer()
    var addButton = UIButton.buttonOfShape(.plus)
    var iButton = UIButton.buttonOfShape(.i)
    let collectionView: UICollectionView
    let draggingHandler: CellDraggingHandler
    let flowLayout = UICollectionViewFlowLayout()
    let settingsViewController = SettingsViewController()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        draggingHandler = CellDraggingHandler(collectionView: self.collectionView)
        collectionView.registerClass(RoundCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        collectionView.dataSource = self
        collectionView.delegate = self
        draggingHandler.delegate = self
    }
    
    override func viewDidLoad() {
        view.addSubview(collectionView)
        constrain(collectionView) { collectionView in
            collectionView.center == collectionView.superview!.center
            collectionView.size == collectionView.superview!.size
        }
        collectionView.backgroundColor = settingsViewController.currentTheme.currentTheme.dominantTheme
        
        view.addSubview(addButton)
        constrain(addButton) { addButton in
            addButton.centerX == addButton.superview!.centerX * 1.7
            addButton.centerY == addButton.superview!.centerY * 0.3
        }
        addButton.addTarget(self, action: #selector(addRoundButtonTapped), forControlEvents: .TouchUpInside)
        
        view.addSubview(iButton)
        constrain(iButton) { iButton in
            iButton.centerX == iButton.superview!.centerX * 0.2
            iButton.centerY == iButton.superview!.centerY * 0.3
        }
        iButton.addTarget(self, action: #selector(iButtonTapped), forControlEvents: .TouchUpInside)
        
        flowLayout.itemSize = CGSize(width: 384, height: 512)
        // One vertical scrolling collumn.
        flowLayout.minimumInteritemSpacing = 1000
        flowLayout.scrollDirection = .Horizontal
    }
    
    var roundToDelete: Round? = nil
    
    func delete(indexPath: NSIndexPath, completion: (shouldDelete: Bool) -> ()) {
        //FIXME: Remove these buttons as soon as the drag is started.
        iButton.removeFromSuperview()
        addButton.removeFromSuperview()
        roundToDelete = .roundForName(viewProducer.getViewControllers()[indexPath.row].title!)
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete \(roundToDelete!.name)?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { action in
            self.viewProducer.removeViewAtIndex(indexPath.row)
            completion(shouldDelete: true)
            self.collectionView.deleteItemsAtIndexPaths([indexPath])
            self.collectionView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            completion(shouldDelete: false)
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deleteDidOccur() {
        let queue = dispatch_queue_create("delete_queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue) {
            self.roundToDelete?.delete()
            dispatch_sync(dispatch_get_main_queue()) {
                self.viewProducer.invalidateViews()
                self.viewProducer.invalidateViewControllers()
                self.roundToDelete = nil
            }
        }
    }
    
    func iButtonTapped() {
        settingsViewController.modalPresentationStyle = .FormSheet
        presentViewController(settingsViewController, animated: true, completion: nil)
    }
    
    func themeDidChange(theme: ColorTheme) {
        viewProducer.getViewControllers().forEach { vc in
            vc.updateTheme(theme)
        }
        viewProducer.invalidateViews()
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .None, animated: false)
        collectionView.backgroundColor = theme.dominantTheme
        iButton.updateTheme(theme, shape: .i)
        addButton.updateTheme(theme, shape: .plus)
    }
    
    func addRoundButtonTapped() {
        let createRoundViewController = CreateRoundViewController(theme: settingsViewController.currentTheme.currentTheme)
        createRoundViewController.modalPresentationStyle = .FormSheet
        presentViewController(createRoundViewController, animated: true, completion: nil)
    }
    
    //FIXME: Develop a better way to handle buttons on top of the collectionView.
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewProducer.getViews().count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! RoundCollectionViewCell
        cell.draggingHandler = draggingHandler
        let view = viewProducer.getViews()[indexPath.row]
        cell.contentView.addSubview(view)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let viewController = viewProducer.getViewControllers()[indexPath.row]
        viewController.transitioningDelegate = self
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    //NOTE: This method is responsible for writing to disk.
    func addRound(round: Round) {
        round.writeToDisk()
        viewProducer.invalidateViews()
        viewProducer.invalidateViewControllers()
        collectionView.reloadData()
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
