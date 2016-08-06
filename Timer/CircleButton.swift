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
    
    var accentColor: UIColor = .cyan {
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
        contentMode = .redraw
    }
    
    func setupLabel(_ label: UILabel) {
        label.textColor = accentColor
        label.font = UIFont.systemFont(ofSize: 20)
        // The baseline keeps the label vertically aligned in the center of the circle, while the textAlignment property keeps the label horizontally aligned.
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .center
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
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.midX, y: rect.midY))
        
        bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.size.width / 2, startAngle: CGFloat(M_PI), endAngle: CGFloat(-M_PI), clockwise: false)

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = bezierPath.cgPath
        
        layer.mask = shapeLayer
    }
    
    override func tintColorDidChange() {
        backgroundColor = superview?.tintColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.backgroundColor = UIColor.gray
        overlayView.alpha = 0.5
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Mask ends here.
        overlayView.removeFromSuperview()
        sendActions(for: .touchUpInside)
    }

    // As per documentation, implement these so as to prevent the iOS from moving up the responder chain.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
