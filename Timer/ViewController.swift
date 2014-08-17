//
//  ViewController.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tickerView: TickerView
    
    required init(coder aDecoder: NSCoder!) {
        self.tickerView = TickerView(frame: CGRect())
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xConstriant = NSLayoutConstraint(item: self.tickerView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: self.tickerView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        let widthConstriant = NSLayoutConstraint(item: self.tickerView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstriant = NSLayoutConstraint(item: self.tickerView, attribute: .Height, relatedBy: .Equal, toItem: self.tickerView, attribute: .Width, multiplier: 1, constant: 0)
        
        self.view.addSubview(self.tickerView)
        NSLayoutConstraint.activateConstraints([xConstriant, yConstraint, widthConstriant, heightConstriant])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
