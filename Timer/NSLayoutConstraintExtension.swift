//
//  NSLayoutConstraintExtension.swift
//  Timer
//
//  Created by E&Z Pierson on 9/1/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    class func generateConstraints(label: UILabel, toItem: UIView, xMultiplier: CGFloat, yMultiplier: CGFloat) -> (xConstraint: NSLayoutConstraint, yConstraint: NSLayoutConstraint) {
        let xConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: toItem, attribute: .CenterX, multiplier: xMultiplier, constant: 0)
        xConstraint.identifier = "X constraint for label: \(label.hash)"
       
        let yConstraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: toItem, attribute: .CenterY, multiplier: yMultiplier, constant: 0)
        yConstraint.identifier = "Y constraint for label: \(label.hash)"
        
        return (xConstraint, yConstraint)
    }
}
