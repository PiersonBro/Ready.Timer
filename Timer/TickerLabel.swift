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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        index = 0
        super.init(frame: frame)
        textAlignment = .Center
        baselineAdjustment = .AlignCenters
        adjustsFontSizeToFitWidth = true
    }
}
