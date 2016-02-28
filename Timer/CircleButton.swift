//
//  CircleButton.swift
//  Timer
//
//  Created by E&Z Pierson on 9/23/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import UIKit
import Cartography

class CircleButton: UIControl {
    private let label: UILabel
    private let overlayView: UIView
    
    var accentColor: UIColor = .cyanColor() {
        didSet {
            label.textColor = accentColor
        }
    }
    
    
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
        setupLabel(label)
        // FIXME: This leads to janky rotation animations, and should be fixed before release.
        contentMode = .Redraw
    }
    
    func setupLabel(label: UILabel) {
        label.textColor = accentColor
        label.font = UIFont.systemFontOfSize(20)
        // The baseline keeps the label vertically aligned in the center of the circle, while the textAlignment property keeps the label horizontally aligned.
        label.baselineAdjustment = .AlignCenters
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true

        addSubview(label)
        constrain(label, self) { (label, view) in
            label.center == view.center
            label.size == view.size
        }
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
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        backgroundColor = newSuperview?.tintColor
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.5
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Mask ends here.
        overlayView.removeFromSuperview()
        sendActionsForControlEvents(.TouchUpInside)
    }

    // As per documentation, implement these so as to prevent the iOS from moving up the responder chain.
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
}
