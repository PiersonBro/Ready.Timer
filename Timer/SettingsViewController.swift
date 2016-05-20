//
//  SettingsViewController.swift
//  Timer
//
//  Created by EandZ on 3/30/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

let identifier = "SettingsCell"
let currentThemeIdentifier = "currentThemeIdentifier"
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView(frame: CGRect())
    let colorThemes: [ColorTheme] = [DefaultTheme(), SecondTheme(), ThirdTheme(), FourthTheme()]
    let currentTheme = CurrentTheme()
    
    override func viewDidLoad() {
        view.addSubview(tableView)
        constrain(tableView) { tableView in
            tableView.center == tableView.superview!.center
            tableView.size == tableView.superview!.size
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collectionViewController = presentingViewController as? RoundCollectionViewController
        currentTheme.currentTheme = colorThemes[indexPath.row]
        collectionViewController!.themeDidChange(currentTheme.currentTheme)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorThemes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        cell.textLabel!.text = colorThemes[indexPath.row].identifier
        //FIXME: ColorTheme isn't equtable.
        if currentTheme.currentTheme.backgroundColor == colorThemes[indexPath.row].backgroundColor {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
}

class CurrentTheme {
    var currentTheme = CurrentTheme.getCurrentTheme() {
        didSet {
            let catfish = NSUserDefaults.standardUserDefaults()
            catfish.setValue(currentTheme.identifier, forKey: currentThemeIdentifier)
        }
    }

    static private func getCurrentTheme() -> ColorTheme {
        let defaults = NSUserDefaults.standardUserDefaults()
        let identifier = defaults.stringForKey(currentThemeIdentifier) ?? "Default"
        return CurrentTheme.colorThemeForIdentifier(identifier)
    }
    
    static func colorThemeForIdentifier(identifier: String) -> ColorTheme {
        let result: [ColorTheme] = [DefaultTheme(), SecondTheme(), ThirdTheme(), FourthTheme()].filter { theme in
            return theme.identifier == identifier
        }
        
        return result.first!
    }
}



