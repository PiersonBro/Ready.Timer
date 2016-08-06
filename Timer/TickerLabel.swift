//
//  TickerLabel.swift
//  Timer
//
//  Created by E&Z Pierson on 9/13/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit

class TickerLabel: UILabel {
    var index: Int
    var consumed = false
    /// Before adding to a dynamic animator be sure to change the snapPoint property.
    /// On `TickerLabel` init `snapBehavior.snapPoint` is `CGPoint()`
    var snapBehavior: UISnapBehavior? = nil
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        index = 0
        super.init(frame: frame)
        textAlignment = .center
        baselineAdjustment = .alignCenters
        adjustsFontSizeToFitWidth = true
        snapBehavior = UISnapBehavior(item: self, snapTo: CGPoint())
    }
}
