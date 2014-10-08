//
//  CircleButton.swift
//  Timer
//
//  Created by E&Z Pierson on 9/23/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit

class CircleButton: UIControl {
    private let label: UILabel
    private let overlayView: UIView
   
    var labelText: String? {
        set {
            self.label.text = newValue 
        }
        get {
            return self.label.text
        }
    }

    override init(frame: CGRect) {
        label = UILabel(frame: CGRect())
        overlayView = UIView(frame: frame)
        super.init(frame: frame)
        backgroundColor = UIColor.purpleColor()
        setupLabel(label)
        // FIXME: This leads to janky rotation animations, and should be fixed before release.
        contentMode = .Redraw
    }
    
    
    func setupLabel(label: UILabel) {
        label.textColor = UIColor.cyanColor()
        label.font = UIFont.systemFontOfSize(20)
        // The baseline keeps the label vertically aligned in the center of the circle, while the textAlignment property keeps the label horizontally aligned.
        label.baselineAdjustment = .AlignCenters
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true

        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let xConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        
        addSubview(label)
        NSLayoutConstraint.activateConstraints([xConstraint, yConstraint,  widthConstraint, heightConstraint])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func drawRect(rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)))
        
        bezierPath.addArcWithCenter(CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)), radius: rect.size.width / 2, startAngle: CGFloat(M_PI), endAngle: CGFloat(-M_PI), clockwise: false)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = bezierPath.CGPath
        
        layer.mask = shapeLayer
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.5
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // Mask ends here.
        overlayView.removeFromSuperview()
        sendActionsForControlEvents(.TouchUpInside)
    }

    // As per documentation, implement these so as to prevent the iOS from moving up the responder chain.
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
}
