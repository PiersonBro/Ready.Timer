//
//  UIConfigurationType.swift
//  Timer
//
//  Created by EandZ on 10/15/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import UIKit

protocol UIConfigurationType {
    var ringerEnabled: Bool {get}
}

extension UIConfigurationType {
    var ringerEnabled: Bool {
        return true
    }
}

struct DefaultConfiguration: UIConfigurationType {}

struct InfiniteUIConfiguration: UIConfigurationType {
    let ringerEnabled = false
}
