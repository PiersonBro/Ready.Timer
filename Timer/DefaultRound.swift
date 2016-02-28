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
    case defaultRound
    case didCopy
    case roundNamesToUpload
    case roundNamesToDelete
}

extension Round {
    static func defaultRound() -> Round? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let name = userDefaults.stringForKey(DefaultsKey.defaultRound.rawValue)
        if let name = name {
            return Round.roundForName(name)
        } else {
            return nil
        }
    }
    
    func registerAsDefaultRound() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(self.name, forKey: DefaultsKey.defaultRound.rawValue)
    }
    
    static func allRounds() -> [Round] {
        let fileManager = NSFileManager.defaultManager()
        var rounds = [Round]()
        
        if let paths = try? fileManager.contentsOfDirectoryAtPath(FSKeys.folderPath) {
            let names = paths.map {(($0 as NSString).lastPathComponent as NSString).stringByDeletingPathExtension}
            names.flatMap {Round.roundForName($0)}.forEach { rounds.append($0) }
        }
        
        return rounds
    }
    
    static func copyResourceFilesToDocuments() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey(DefaultsKey.didCopy.rawValue) {
            ["LincolnDouglas", "Parli", "TeamPolicy"].forEach {
                if Round.roundForName($0) == nil {
                    Round.addRoundNameToUpload($0)
                    let fileManager = NSFileManager.defaultManager()
                    let source = NSBundle.mainBundle().pathForResource($0, ofType: "plist")
                    let filePath = FSKeys.pathForName($0)
                    if !fileManager.fileExistsAtPath((filePath as NSString).stringByDeletingLastPathComponent) {
                        try! fileManager.createDirectoryAtPath(FSKeys.folderPath, withIntermediateDirectories: false, attributes: nil)
                    }
                    try! fileManager.copyItemAtPath(source!, toPath: filePath)
                }
                defaults.setBool(true, forKey: DefaultsKey.didCopy.rawValue)
            }
        }
    }
    
    static func addRoundNameToUpload(name: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(roundNamesToUpload() + [name], forKey: DefaultsKey.roundNamesToUpload.rawValue)
    }
    
    static func removeRoundNameToUpload(name: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var hardwareBound = roundNamesToUpload()
        let index = hardwareBound.indexOf(name)
        
        if let index = index {
            hardwareBound.removeAtIndex(index)
            defaults.setObject(hardwareBound, forKey: DefaultsKey.roundNamesToUpload.rawValue)
        }
    }
    
    static func roundNamesToUpload() -> [String] {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.arrayForKey(DefaultsKey.roundNamesToUpload.rawValue) as? [String] ?? []
    }
    
    
    
    static func addRoundNameToDelete(name: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(roundNamesToDelete() + [name], forKey: DefaultsKey.roundNamesToDelete.rawValue)
    }
    
    static func removeRoundNameToDelete(name: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var hardwareBound = roundNamesToDelete()
        let index = hardwareBound.indexOf(name)
        
        if let index = index {
            hardwareBound.removeAtIndex(index)
            defaults.setObject(hardwareBound, forKey: DefaultsKey.roundNamesToDelete.rawValue)
        }
    }
    
    static func roundNamesToDelete() -> [String] {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.arrayForKey(DefaultsKey.roundNamesToDelete.rawValue) as? [String] ?? []
    }

}
