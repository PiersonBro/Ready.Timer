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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        draggingHandler = CellDraggingHandler(collectionView: self.collectionView)
        collectionView.register(RoundCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
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
        addButton.addTarget(self, action: #selector(addRoundButtonTapped), for: .touchUpInside)
        
        view.addSubview(iButton)
        constrain(iButton) { iButton in
            iButton.centerX == iButton.superview!.centerX * 0.2
            iButton.centerY == iButton.superview!.centerY * 0.3
        }
        iButton.addTarget(self, action: #selector(iButtonTapped), for: .touchUpInside)
        
        flowLayout.itemSize = CGSize(width: 384, height: 512)
        // One vertical scrolling collumn.
        flowLayout.minimumInteritemSpacing = 1000
        flowLayout.scrollDirection = .horizontal
    }
    
    var roundToDelete: Round? = nil
    
    func delete(_ indexPath: IndexPath, completion: (shouldDelete: Bool) -> ()) {
        //FIXME: Remove these buttons as soon as the drag is started.
        iButton.removeFromSuperview()
        addButton.removeFromSuperview()
        roundToDelete = .roundForName(viewProducer.getViewControllers()[(indexPath as NSIndexPath).row].title!)
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete \(roundToDelete!.name)?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.viewProducer.removeViewAtIndex((indexPath as NSIndexPath).row)
            completion(shouldDelete: true)
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            completion(shouldDelete: false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteDidOccur() {
        let queue = DispatchQueue(label: "delete_queue", attributes: .concurrent)
        queue.async {
            self.roundToDelete?.delete()
            DispatchQueue.main.sync {
                self.viewProducer.invalidateViews()
                self.viewProducer.invalidateViewControllers()
                self.roundToDelete = nil
            }
        }
    }
    
    func iButtonTapped() {
        settingsViewController.modalPresentationStyle = .formSheet
        present(settingsViewController, animated: true, completion: nil)
    }
    
    func themeDidChange(_ theme: ColorTheme) {
        viewProducer.getViewControllers().forEach { vc in
            vc.updateTheme(theme)
        }
        viewProducer.invalidateViews()
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: UICollectionViewScrollPosition(), animated: false)
        collectionView.backgroundColor = theme.dominantTheme
        iButton.updateTheme(theme, shape: .i)
        addButton.updateTheme(theme, shape: .plus)
    }
    
    func addRoundButtonTapped() {
        let createRoundViewController = CreateRoundViewController(theme: settingsViewController.currentTheme.currentTheme)
        createRoundViewController.modalPresentationStyle = .formSheet
        present(createRoundViewController, animated: true, completion: nil)
    }
    
    //FIXME: Develop a better way to handle buttons on top of the collectionView.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewProducer.getViews().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! RoundCollectionViewCell
        cell.draggingHandler = draggingHandler
        let view =
            viewProducer.getViews()[(indexPath as NSIndexPath).row]
        cell.contentView.addSubview(view)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = viewProducer.getViewControllers()[(indexPath as NSIndexPath).row]
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    //NOTE: This method is responsible for writing to disk.
    func addRound(_ round: Round) {
        round.writeToDisk()
        viewProducer.invalidateViews()
        viewProducer.invalidateViewControllers()
        collectionView.reloadData()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Code taken from iOS 7 demos.
        let indexPath = collectionView.indexPathsForSelectedItems![0]
        let cell = collectionView.cellForItem(at: indexPath)
        let containerView = transitionContext.containerView
        let viewControllerFrom = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        let viewControllerTo = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        let fromView = viewControllerFrom.view
        let toView = viewControllerTo.view
        let beginFrame = containerView.convert(cell!.bounds, from: cell)
        let endFrame = transitionContext.initialFrame(for: viewControllerFrom)
        var move: UIView? = nil
        
        if viewControllerTo.isBeingPresented {
            toView?.frame = endFrame
            move = toView?.snapshotView(afterScreenUpdates: true)
            move?.frame = beginFrame
            cell?.isHidden = true
        } else {
            move = fromView?.snapshotView(afterScreenUpdates: true)
            move?.frame = fromView!.frame
            fromView?.removeFromSuperview()
            containerView.addSubview(toView!)
        }
        
        containerView.addSubview(move!)
            
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 500, initialSpringVelocity: 15, options: UIViewAnimationOptions(rawValue: 0), animations: {
                move!.frame = viewControllerTo.isBeingPresented ? endFrame : beginFrame
        }, completion: { success in
            if viewControllerTo.isBeingPresented {
                move?.removeFromSuperview()
                toView?.frame = endFrame
                containerView.addSubview(toView!)
                transitionContext.completeTransition(true)

            } else {
                cell?.isHidden = false
                transitionContext.completeTransition(true)
            }
        })
    }
}
