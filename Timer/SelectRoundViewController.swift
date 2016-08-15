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
    private let tableView = UITableView(frame: CGRect(), style: .plain)
    private let toolbar = UIToolbar(frame: CGRect())
    let toolbarDelegate = BarPositionDelegate()
    let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
    var topConstraint: NSLayoutConstraint? = nil
    let theme: ColorTheme
    
    init(rounds: [Round], theme: ColorTheme) {
        self.rounds = rounds
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(toolbar)
        view.addSubview(statusBarView)
        
        view.tintColor = theme.dominantTheme
        
        let shouldBeUnderStatusBar: Bool
        if UIDevice.current.userInterfaceIdiom == .phone {
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
            doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        } else {
            doneButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        }
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRound))
        toolbar.items = [doneButton, spacer, addButton]

        toolbar.delegate = toolbarDelegate
        toolbar.setBackgroundImage(nil, forToolbarPosition: .topAttached, barMetrics: .compact)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = rounds[(indexPath as NSIndexPath).row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedRound = rounds[(indexPath as NSIndexPath).row]
        let partialEngine = RoundUIEngine.createEngine(selectedRound)
        let viewController = ViewController(partialEngine: partialEngine)
        presentingViewController?.dismiss(animated: true) {
            UIApplication.shared.delegate?.window!?.rootViewController = viewController
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            let round = self.rounds[(indexPath as NSIndexPath).row]
            round.delete()
            self.rounds.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let setDefaultRowAction = UITableViewRowAction(style: .normal, title: "Set as Default") { action, indexPath in
            let round = self.rounds[(indexPath as NSIndexPath).row]
            round.registerAsDefaultRound()
            tableView.setEditing(false, animated: true)
        }
        setDefaultRowAction.backgroundColor = theme.dominantTheme

        
        return [deleteRowAction, setDefaultRowAction]
    }
    
    func addRound() {
        let createRoundVC = CreateRoundViewController(theme: theme)
        presentingViewController?.dismiss(animated: true) {
            if let rootViewController = UIApplication.shared.delegate?.window!?.rootViewController {
                rootViewController.present(createRoundVC, animated: true, completion: nil)
            } else {
                fatalError("HMM")
            }
        }
    }

    func done() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && UIDevice.current.userInterfaceIdiom == .phone {
            NSLayoutConstraint.deactivate([topConstraint!])
            constrain(toolbar) { toolbar in
                self.topConstraint = toolbar.top == toolbar.superview!.top
            }
        } else if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) && UIDevice.current.userInterfaceIdiom == .phone {
            NSLayoutConstraint.deactivate([topConstraint!])
            constrain(toolbar, statusBarView) { toolbar, statusBarView in
                self.topConstraint = toolbar.top == statusBarView.bottom
            }
        }
    }
}

class BarPositionDelegate: NSObject, UIToolbarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
