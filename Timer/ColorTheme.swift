//
//  ColorTheme.swift
//  Timer
//
//  Created by EandZ on 4/2/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import UIKit

protocol ColorTheme {
    var dominantTheme: UIColor { get }
    var backgroundColor: UIColor { get }
    var accentColor: UIColor { get }
    var identifier: String {get}
}

extension ColorTheme {
    var identifier: String {
        return "Default"
    }
    
    var dominantTheme: UIColor {
        return UIColor(red:0.83, green:0.33, blue:0, alpha:1)
    }
    
    var backgroundColor: UIColor {
        return UIColor(red:0.99, green:0.89, blue:0.65, alpha:1)
    }
    
    var accentColor: UIColor {
        return UIColor(red:0.98, green:0.75, blue:0.23, alpha:1)
    }
}

struct DefaultTheme: ColorTheme {}

struct SecondTheme: ColorTheme {
    var dominantTheme: UIColor {
        return UIColor(red:0.27, green:0.42, blue:0.71, alpha:1)
    }
    
    var backgroundColor: UIColor {
        return UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
    }
    
    var accentColor: UIColor {
        return UIColor(red:0.32, green:0.7, blue:0.85, alpha:1)
    }
    
    var identifier: String {
        return "Second"
    }
}

struct ThirdTheme: ColorTheme {
    
    var dominantTheme: UIColor {
        return UIColor(red:0.48, green:0.64, blue:0.66, alpha:1)
    }
    
    var backgroundColor: UIColor {
        return UIColor(red:0.89, green:0.95, blue:1, alpha:1)
    }
    
    var accentColor: UIColor {
        return UIColor(red:0.78, green:0.97, blue:0.77, alpha:1)
    }
    
    var identifier: String {
        return "Third"
    }
}


struct FourthTheme: ColorTheme {
    var dominantTheme: UIColor {
        return UIColor(red:0.51, green:0.19, blue:0.11, alpha:1.00)
    }
    
    var backgroundColor: UIColor {
        return UIColor(red:0.55, green:0.31, blue:0.22, alpha:1.00) //UIColor(red:0.85, green:0.54, blue:0.23, alpha:1.00)
    }
    
    var accentColor: UIColor {
        return UIColor(red:0.85, green:0.54, blue:0.23, alpha:1.00)
    }
    
    var identifier: String {
        return "Fourth"
    }
}
