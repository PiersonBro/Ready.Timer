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
    
    required init(coder aDecoder: NSCoder) {
        tickerView = TickerView(frame: CGRect())
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xConstriant = NSLayoutConstraint(item: tickerView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: tickerView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        let widthConstriant = NSLayoutConstraint(item: tickerView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstriant = NSLayoutConstraint(item: tickerView, attribute: .Height, relatedBy: .Equal, toItem: tickerView, attribute: .Width, multiplier: 1, constant: 0)

        view.addSubview(tickerView)
        NSLayoutConstraint.activateConstraints([xConstriant, yConstraint, widthConstriant, heightConstriant])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
