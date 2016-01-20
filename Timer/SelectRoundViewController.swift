//
//  SelectRoundViewController.swift
//  Timer
//
//  Created by EandZ on 11/19/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

let reuseIdentifier = "ReuseIdentifier"
class SelectRoundViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var rounds: [Round]
    private let tableView = UITableView(frame: CGRect(), style: .Plain)
    private let toolbar = UIToolbar(frame: CGRect())
    let toolbarDelegate = BarPositionDelegate()
    let statusBarView = UIView(frame: UIApplication.sharedApplication().statusBarFrame ?? CGRect())
    var topConstraint: NSLayoutConstraint? = nil

    init(rounds: [Round]) {
        self.rounds = rounds
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(toolbar)
        view.addSubview(statusBarView)
        
        let shouldBeUnderStatusBar: Bool
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            shouldBeUnderStatusBar = true
        } else {
            shouldBeUnderStatusBar = false
        }
        
        constrain(tableView, toolbar,statusBarView) { tableView, toolbar, statusBarView in
            tableView.height == (tableView.superview!.height - 45)
            tableView.bottom == tableView.superview!.bottom
            tableView.width == tableView.superview!.width
            toolbar.bottom == tableView.top
            if shouldBeUnderStatusBar {
                topConstraint = toolbar.top == statusBarView.bottom
            } else {
                topConstraint = toolbar.top == toolbar.superview!.top
            }
            toolbar.width == toolbar.superview!.width
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        let doneButton: UIBarButtonItem
        if let _ = Round.defaultRound() {
            doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        } else {
            doneButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: "")
        }
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addRound")
        toolbar.items = [doneButton, spacer, addButton]
        toolbar.tintColor = .purpleColor()

        toolbar.delegate = toolbarDelegate
        toolbar.setBackgroundImage(nil, forToolbarPosition: .TopAttached, barMetrics: .Compact)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rounds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = rounds[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let selectedRound = rounds[indexPath.row]
        let partialEngine = RoundUIEngine.createEngine(selectedRound)
        let viewController = ViewController(partialEngine: partialEngine)
        presentingViewController?.dismissViewControllerAnimated(true) {
            UIApplication.sharedApplication().delegate?.window!?.rootViewController = viewController
        }
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var rowActions: [UITableViewRowAction] = []
        
        if !isDebateName(rounds[indexPath.row].name) {
            let deleteRowAction = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
                let round = self.rounds[indexPath.row]
                round.delete()
                self.rounds.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            rowActions.append(deleteRowAction)
        }
        
        let setDefaultRowAction = UITableViewRowAction(style: .Normal, title: "Set as Default") { action, indexPath in
            let round = self.rounds[indexPath.row]
            round.registerAsDefaultRound()
            tableView.setEditing(false, animated: true)
        }
        setDefaultRowAction.backgroundColor = .purpleColor()
        rowActions.append(setDefaultRowAction)
        
        return rowActions
    }
    
    private func isDebateName(name: String) -> Bool {
        switch name {
            case DebateType.LincolnDouglas.rawValue:
                return true
            case DebateType.Parli.rawValue:
                return true
            case DebateType.TeamPolicy.rawValue:
                return true
            default:
                return false
        }
    }

    func addRound() {
        let createRoundVC = CreateRoundViewController()
        presentingViewController?.dismissViewControllerAnimated(true) {
            if let rootViewController = UIApplication.sharedApplication().delegate?.window!?.rootViewController {
                rootViewController.presentViewController(createRoundVC, animated: true, completion: nil)
            } else {
                fatalError("HMM")
            }
        }
    }

    func done() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) && UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            NSLayoutConstraint.deactivateConstraints([topConstraint!])
            constrain(toolbar) { toolbar in
                self.topConstraint = toolbar.top == toolbar.superview!.top
            }
        } else if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) && UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            NSLayoutConstraint.deactivateConstraints([topConstraint!])
            constrain(toolbar, statusBarView) { toolbar, statusBarView in
                self.topConstraint = toolbar.top == statusBarView.bottom
            }
        }
    }
}

class BarPositionDelegate: NSObject, UIToolbarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
