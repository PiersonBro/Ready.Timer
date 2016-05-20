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
    
    func image(colorTheme: ColorTheme) -> UIImage {
        if self == .i {
            let rect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            let movePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMaxY(rect))
            CGContextMoveToPoint(context, movePoint.x, movePoint.y)
        
            let linePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect) - 60)
            CGContextAddLineToPoint(context, linePoint.x, linePoint.y)
            CGContextSetStrokeColorWithColor(context, colorTheme.accentColor.CGColor)
            CGContextSetLineWidth(context, 10)
            CGContextStrokePath(context)
        
            let olinePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect) - 90)
            CGContextMoveToPoint(context, olinePoint.x, olinePoint.y)
            CGContextAddLineToPoint(context, olinePoint.x, olinePoint.y - 80)
            CGContextStrokePath(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return image
        } else if self == .plus {
            let rect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            let movePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMaxY(rect))
            CGContextMoveToPoint(context, movePoint.x, movePoint.y)
            
            let linePoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMinY(rect))
            CGContextAddLineToPoint(context, linePoint.x, linePoint.y)
            CGContextSetStrokeColorWithColor(context, colorTheme.accentColor.CGColor)
            CGContextSetLineWidth(context, 5)
            CGContextStrokePath(context)
            
            let rightMovePoint = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMidY(rect))
            CGContextMoveToPoint(context, rightMovePoint.x, rightMovePoint.y)
            let pointToMoveTo = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMidY(rect))
            CGContextAddLineToPoint(context, pointToMoveTo.x, pointToMoveTo.y)
            CGContextStrokePath(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        } else {
            fatalError()
        }
 
    }
}

extension UIButton {
    static func buttonOfShape(shape: ButtonShape) -> UIButton {
        let image = shape.image(CurrentTheme().currentTheme)
        let button = UIButton(type: .Custom)
        button.setImage(image, forState: .Normal)
        return button
    }
    
    func updateTheme(theme: ColorTheme, shape: ButtonShape) {
        let image = shape.image(CurrentTheme().currentTheme)
        setImage(image, forState: .Normal)
    }
}
