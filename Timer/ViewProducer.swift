//
//  ViewProducer.swift
//  Timer
//
//  Created by EandZ on 5/17/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import Foundation

final class ViewProducer {
    private var views: [UIView]?
    private var viewControllers: [ViewController]?
    private static func produceViewControllers() -> [ViewController] {
        let allRounds = Round.allRounds()
        let vcs = allRounds.map {
            ViewController(partialEngine: RoundUIEngine.createEngine($0))
        }
        return vcs
    }
    
    private static func produceViews(viewControllers: [ViewController]) -> [UIView] {
        let views = viewControllers.map { vc -> UIView in
            vc.updateTheme(CurrentTheme().currentTheme)
            let view = vc.view.snapshotViewAfterScreenUpdates(true)
            view.bounds.size = CGSize(width: 384, height: 512)
            view.bounds.origin = CGPoint(x: 0, y: 0)
            return view
            }.map { view -> UIView in
                return view.snapshotViewAfterScreenUpdates(true)
        }
        
        return views
    }
    
    init() {
        viewControllers = nil
        views = nil
    }
    
    func getViewControllers() -> [ViewController] {
        if let viewControllers = viewControllers {
            return viewControllers
        } else {
            viewControllers = ViewProducer.produceViewControllers()
            return viewControllers!
        }
    }
    
    func getViews() -> [UIView] {
        if let storage = views {
            return storage
        } else {
            views = ViewProducer.produceViews(getViewControllers())
            return views!
        }
    }
    
    // Remove the view without deleting it, this is a performance optimazation.
    func removeViewAtIndex(index: Int) {
        if let storage = views {
            var newStorage = storage
            newStorage.removeAtIndex(index)
            self.views = newStorage
            viewControllers?.removeAtIndex(index)
        }
    }
    
    func invalidateViews() {
        views = nil
    }
    
    func invalidateViewControllers() {
        viewControllers = nil
    }
}
