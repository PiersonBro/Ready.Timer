//
//  ShapeButton.swift
//  Timer
//
//  Created by EandZ on 3/27/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import UIKit

enum ButtonShape {
    case plus
    case i
    
    func image(_ colorTheme: ColorTheme) -> UIImage {
        if self == .i {
            let rect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            let movePoint = CGPoint(x: rect.midX, y: rect.maxY)
            context?.moveTo(x: movePoint.x, y: movePoint.y)
        
            let linePoint = CGPoint(x: rect.midX, y: rect.midY - 60)
            context?.addLineTo(x: linePoint.x, y: linePoint.y)
            context?.setStrokeColor(colorTheme.accentColor.cgColor)
            context?.setLineWidth(10)
            context?.strokePath()
        
            let olinePoint = CGPoint(x: rect.midX, y: rect.midY - 90)
            context?.moveTo(x: olinePoint.x, y: olinePoint.y)
            context?.addLineTo(x: olinePoint.x, y: olinePoint.y - 80)
            context?.strokePath()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return image!
        } else if self == .plus {
            let rect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            let movePoint = CGPoint(x: rect.midX, y: rect.maxY)
            context?.moveTo(x: movePoint.x, y: movePoint.y)
            
            let linePoint = CGPoint(x: rect.midX, y: rect.minY)
            context?.addLineTo(x: linePoint.x, y: linePoint.y)
            context?.setStrokeColor(colorTheme.accentColor.cgColor)
            context?.setLineWidth(5)
            context?.strokePath()
            
            let rightMovePoint = CGPoint(x: rect.maxX, y: rect.midY)
            context?.moveTo(x: rightMovePoint.x, y: rightMovePoint.y)
            let pointToMoveTo = CGPoint(x: rect.minX, y: rect.midY)
            context?.addLineTo(x: pointToMoveTo.x, y: pointToMoveTo.y)
            context?.strokePath()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image!
        } else {
            fatalError()
        }
 
    }
}

extension UIButton {
    static func buttonOfShape(_ shape: ButtonShape) -> UIButton {
        let image = shape.image(CurrentTheme().currentTheme)
        let button = UIButton(type: .custom)
        button.setImage(image, for: UIControlState())
        return button
    }
    
    func updateTheme(_ theme: ColorTheme, shape: ButtonShape) {
        let image = shape.image(CurrentTheme().currentTheme)
        setImage(image, for: UIControlState())
    }
}
