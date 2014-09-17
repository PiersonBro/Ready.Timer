//
//  TickerView.swift
//  Timer
//
//  Created by E&Z Pierson on 8/16/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import QuartzCore

class TickerView: UIView {
    // Subviews
    let bottommostLabel: UILabel
    let rightmostLabel: UILabel
    let topmostLabel: UILabel
    let leftmostLabel: UILabel
    
    // Strongly held animator objects
    let animator: UIDynamicAnimator
    var snapBehaviors: [UISnapBehavior]
    let labels: [UILabel]
    
    required init(coder aDecoder: NSCoder!) {
        self.bottommostLabel = UILabel()
        self.rightmostLabel = UILabel()
        self.topmostLabel = UILabel()
        self.leftmostLabel = UILabel()
        
        self.animator = UIDynamicAnimator()
        self.snapBehaviors = []
        self.labels = [self.bottommostLabel, self.rightmostLabel, self.topmostLabel, self.leftmostLabel]
        
        super.init(coder: aDecoder)
        
        assert(false == true, "Don't use this")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Initializer Not Supported")
    }

    override init(frame: CGRect) {
        self.bottommostLabel = UILabel()
        self.rightmostLabel = UILabel()
        self.topmostLabel = UILabel()
        self.leftmostLabel = UILabel()
        
        self.animator = UIDynamicAnimator()
        self.snapBehaviors = []
        self.labels = [self.bottommostLabel, self.rightmostLabel, self.topmostLabel, self.leftmostLabel]
      
        super.init(frame: frame)
      
        self.bottommostLabel = configureLabel(self.bottommostLabel, text: "2 AC", xMultiplier: 1.5, yMultiplier: 0.7)
        self.rightmostLabel = configureLabel(self.rightmostLabel, text: "2 NC", xMultiplier: 1, yMultiplier: 1.5)
        self.topmostLabel = configureLabel(self.topmostLabel, text: "1 AC", xMultiplier: 1, yMultiplier: 0.5)
        self.leftmostLabel = configureLabel(self.leftmostLabel, text: "1 NC", xMultiplier: 0.5, yMultiplier: 0.7)
        self.animator = UIDynamicAnimator(referenceView: self)
        self.layer.masksToBounds = true
        self.backgroundColor =  UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        
    }
    
    func configureLabel(label: UILabel, text: String, xMultiplier: CGFloat, yMultiplier: CGFloat) -> UILabel {
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor.cyanColor()
        label.text = text
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: xMultiplier, constant: 0)
        let yConstraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: yMultiplier, constant: 0)
        
        self.addSubview(label)
        NSLayoutConstraint.activateConstraints([xConstraint, yConstraint])
        return label
    }
    
    override func drawRect(rect: CGRect) {
        let mask = CAShapeLayer()
        mask.frame = bounds;
        let point = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(point)
        bezierPath.addArcWithCenter(point, radius: rect.size.width / 2, startAngle:CGFloat(M_PI), endAngle: CGFloat(M_PI) * 2, clockwise: true)
        mask.path = bezierPath.CGPath
        layer.mask = mask
        
        let leftLineShapeLayer = CAShapeLayer()
        let leftLinePath = UIBezierPath()
        leftLinePath.moveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
        leftLinePath.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
        leftLineShapeLayer.path = leftLinePath.CGPath
        self.layer.addSublayer(leftLineShapeLayer)
        
        let rightLineShapeLayer = CAShapeLayer()
        let rightLinePath = UIBezierPath()
        rightLinePath.moveToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect)))
        rightLinePath.moveToPoint(CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)))
        rightLinePath.moveToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMinY(rect)))
        rightLineShapeLayer.path = rightLinePath.CGPath
        self.layer.addSublayer(rightLineShapeLayer)
    }
}




