//
//  UIConfigurationType.swift
//  Timer
//
//  Created by EandZ on 10/15/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import UIKit

protocol UIConfigurationType {
    var dominantTheme: UIColor { get }
    var backgroundColor: UIColor { get }
    var accentColor: UIColor { get }
    var ringerEnabled: Bool { get }
}

extension UIConfigurationType {
    var dominantTheme: UIColor {
        // UIColor(red:0.48, green:0.64, blue:0.66, alpha:1)
        // UIColor(red:0.27, green:0.42, blue:0.71, alpha:1)
        return UIColor(red:0.83, green:0.33, blue:0, alpha:1)
    }
    
    var backgroundColor: UIColor {
        // /* UIColor(red:0.89, green:0.95, blue:1, alpha:1) */ UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        return UIColor(red:0.99, green:0.89, blue:0.65, alpha:1)
    }
    
    var accentColor: UIColor {
        // /* UIColor(red:0.9, green:0.87, blue:0.26, alpha:1) */ .yellowColor()
        // UIColor(red:0.32, green:0.7, blue:0.85, alpha:1)
        // UIColor(red:0.78, green:0.97, blue:0.77, alpha:1)
        return UIColor(red:0.98, green:0.75, blue:0.23, alpha:1)
    }
    
    var ringerEnabled: Bool {
        return true
    }
}

struct DefaultConfiguration: UIConfigurationType {}

struct InfiniteUIConfiguration: UIConfigurationType {
    let ringerEnabled = false
}
