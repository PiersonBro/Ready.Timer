//
//  StringExtension.swift
//  Timer
//
//  Created by E&Z Pierson on 3/14/15.
//  Copyright (c) 2015 E&Z Pierson. All rights reserved.
//

import Foundation

public extension String {
    
    public static func formattedStringForDuration(duration: NSTimeInterval) -> String {
        let minute = Int(duration) / 60
        let second = Int(duration) % 60
        var secondString = ""
        
        if second < 10 {
            secondString = "0\(second)"
        } else {
            secondString = "\(second)"
        }
        
        return "\(minute):\(secondString)"
    }
}