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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collectionViewController = presentingViewController as? RoundCollectionViewController
        currentTheme.currentTheme = colorThemes[(indexPath as NSIndexPath).row]
        collectionViewController!.themeDidChange(currentTheme.currentTheme)
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorThemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel!.text = colorThemes[(indexPath as NSIndexPath).row].identifier
        //FIXME: ColorTheme isn't equtable.
        if currentTheme.currentTheme.backgroundColor == colorThemes[(indexPath as NSIndexPath).row].backgroundColor {
            cell.accessoryType = .checkmark
        }
        return cell
    }
}

class CurrentTheme {
    var currentTheme = CurrentTheme.getCurrentTheme() {
        didSet {
            let catfish = UserDefaults.standard
            catfish.setValue(currentTheme.identifier, forKey: currentThemeIdentifier)
        }
    }

    static private func getCurrentTheme() -> ColorTheme {
        let defaults = UserDefaults.standard
        let identifier = defaults.string(forKey: currentThemeIdentifier) ?? "Default"
        return CurrentTheme.colorThemeForIdentifier(identifier)
    }
    
    static func colorThemeForIdentifier(_ identifier: String) -> ColorTheme {
        let result: [ColorTheme] = [DefaultTheme(), SecondTheme(), ThirdTheme(), FourthTheme()].filter { theme in
            return theme.identifier == identifier
        }
        
        return result.first!
    }
}



