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
    private let rounds: [Round]
    private let tableView = UITableView(frame: CGRect(), style: .Plain)
    private let toolbar = UIToolbar(frame: CGRect())
    
    init(rounds: [Round]) {
        self.rounds = rounds
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(toolbar)
        constrain(tableView, toolbar) { tableView, toolbar in
            tableView.height == (tableView.superview!.height - 45)
            tableView.bottom == tableView.superview!.bottom
            tableView.width == tableView.superview!.width
            toolbar.bottom == tableView.top
            toolbar.top == toolbar.superview!.top
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
    
    func addRound() {
        let createRoundVC = CreateRoundViewController()
        presentingViewController?.dismissViewControllerAnimated(true) {
            UIApplication.sharedApplication().delegate?.window!?.rootViewController = createRoundVC
        }
    }

    func done() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
