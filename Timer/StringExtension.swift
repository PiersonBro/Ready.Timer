//
//  StringExtension.swift
//  Timer
//
//  Created by E&Z Pierson on 3/14/15.
//  Copyright (c) 2015 E&Z Pierson. All rights reserved.
//

import Foundation

public extension String {
    
    public static func formattedStringForDuration(_ duration: Int) -> String {
        let minute = duration / 60
        let second = duration % 60
        let secondString: String
        
        if second < 10 {
            secondString = "0\(second)"
        } else {
            secondString = "\(second)"
        }
        
        return "\(minute):\(secondString)"
    }
}
