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
    var textColor: UIColor { get }
    var ringerEnabled: Bool { get }
    // FIXME: Figure out if more configuration is needed.
//    var availableUserInteractions: [UserInteraction] { get }
}

//enum UserInteraction {
//    case Right
//    case Left
//    case Center
//}

extension UIConfigurationType {
    var dominantTheme: UIColor {
        return UIColor.purpleColor()
    }
    var textColor: UIColor {
        return UIColor.whiteColor()
    }
    
    var ringerEnabled: Bool {
        return false
    }
}

struct OvertimeTimerUIConfiguration: UIConfigurationType {
    let ringerEnabled = true
}

struct DefaultConfiguration: UIConfigurationType {
    
}
