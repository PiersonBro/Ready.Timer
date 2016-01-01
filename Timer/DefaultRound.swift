//
//  DefaultRound.swift
//  Timer
//
//  Created by EandZ on 11/18/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

enum DefaultsKey: String {
    case DefaultRound
}

extension Round {
    static func defaultRound() -> Round? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let name = userDefaults.stringForKey(DefaultsKey.DefaultRound.rawValue)
        if let name = name {
            if let type = DebateType(rawValue: name) {
                return Round.roundFromDebateType(type)
            } else {
                return Round.roundForName(name)
            }
        } else {
            return nil
        }
    }
    
    func registerAsDefaultRound() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(self.name, forKey: DefaultsKey.DefaultRound.rawValue)
    }
    
    static func allRounds() -> [Round] {
        let fileManager = NSFileManager.defaultManager()
        var rounds = [Round.roundFromDebateType(.Parli), Round.roundFromDebateType(.LincolnDouglas), Round.roundFromDebateType(.TeamPolicy)]
        if let paths = try? fileManager.contentsOfDirectoryAtPath(FSKeys.folderPath) {
            let names = paths.map {(($0 as NSString).lastPathComponent as NSString).stringByDeletingPathExtension}
            names.map {Round.roundForName($0)}.forEach { rounds.append($0) }
        }
        
        return rounds
    }
}
