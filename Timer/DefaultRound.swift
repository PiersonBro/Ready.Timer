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
//FIXME: Rename file.
extension Round {
    static func defaultRound() -> Round? {
        let userDefaults = UserDefaults.standard
        let name = userDefaults.string(forKey: DefaultsKey.defaultRound.rawValue)
        if let name = name {
            return Round.roundForName(name)
        } else {
            return nil
        }
    }
    
    func registerAsDefaultRound() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(self.name, forKey: DefaultsKey.defaultRound.rawValue)
    }
    
    static func allRounds() -> [Round] {
        let fileManager = FileManager.default
        var rounds = [Round]()
        
        if let paths = try? fileManager.contentsOfDirectory(atPath: FSKeys.folderPath) {
            let names = paths.map {(($0 as NSString).lastPathComponent as NSString).deletingPathExtension}
            names.flatMap {Round.roundForName($0)}.forEach { rounds.append($0) }
        }
        
        return rounds
    }
    
    static func copyResourceFilesToDocuments() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: DefaultsKey.didCopy.rawValue) {
            ["LincolnDouglas", "Parli", "TeamPolicy"].forEach {
                if Round.roundForName($0) == nil {
                    Round.addRoundNameToUpload($0)
                    let fileManager = FileManager.default
                    let source = Bundle.main.path(forResource: $0, ofType: "plist")
                    let filePath = FSKeys.pathForName($0)
                    if !fileManager.fileExists(atPath: (filePath as NSString).deletingLastPathComponent) {
                        try! fileManager.createDirectory(atPath: FSKeys.folderPath, withIntermediateDirectories: false, attributes: nil)
                    }
                    try! fileManager.copyItem(atPath: source!, toPath: filePath)
                }
                defaults.set(true, forKey: DefaultsKey.didCopy.rawValue)
            }
        }
    }
    
    static func addRoundNameToUpload(_ name: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(roundNamesToUpload() + [name], forKey: DefaultsKey.roundNamesToUpload.rawValue)
    }
    
    static func removeRoundNameToUpload(_ name: String) {
        let defaults = UserDefaults.standard
        var hardwareBound = roundNamesToUpload()
        let index = hardwareBound.index(of: name)
        
        if let index = index {
            hardwareBound.remove(at: index)
            defaults.set(hardwareBound, forKey: DefaultsKey.roundNamesToUpload.rawValue)
        }
    }
    
    static func roundNamesToUpload() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: DefaultsKey.roundNamesToUpload.rawValue) as? [String] ?? []
    }
   
    static func addRoundNameToDelete(_ name: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(roundNamesToDelete() + [name], forKey: DefaultsKey.roundNamesToDelete.rawValue)
    }
    
    static func removeRoundNameToDelete(_ name: String) {
        let defaults = UserDefaults.standard
        var hardwareBound = roundNamesToDelete()
        let index = hardwareBound.index(of: name)
        
        if let index = index {
            hardwareBound.remove(at: index)
            defaults.set(hardwareBound, forKey: DefaultsKey.roundNamesToDelete.rawValue)
        }
    }
    
    static func roundNamesToDelete() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: DefaultsKey.roundNamesToDelete.rawValue) as? [String] ?? []
    }

}
