//
//  PListCreator.swift
//  Timer
//
//  Created by E&Z Pierson on 9/8/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit
import CloudKit

//FIXME: Move from crazy terrible stupid nil based code, to generic based code.
class PlistCreator {
    var dictionary: [String: AnyObject]?
    var record: CKRecord?
    
    init(record: CKRecord? = nil) {
        self.record = record
        if record != nil {
            dictionary = nil
        } else {
            dictionary = [String: AnyObject]()
        }
    }
    
    func addTimer(ofType typeOfTimer: TimerKind, identifier: String, durationInMinutes: Int) {
        addTimer(ofType: typeOfTimer, identifier: identifier, durationInSeconds: durationInMinutes * 60)
    }
    
    func addTimer(ofType typeOfTimer: TimerKind, identifier: String, durationInSeconds: Int) {
        let newIdentifier = PlistCreator.sanitizeIdentifier(identifier)
        if dictionary != nil {
            dictionary![PlistKeys.TypeOfTimer.rawValue + newIdentifier] = typeOfTimer.rawValue
            dictionary![newIdentifier] = durationInSeconds
            let speeches = dictionary![PlistKeys.Speeches.rawValue] as? [String]
        
            if let speeches = speeches {
                dictionary![PlistKeys.Speeches.rawValue] = speeches + [newIdentifier]
            } else {
                dictionary![PlistKeys.Speeches.rawValue] = [newIdentifier]
            }
        } else if record != nil {
            record![PlistKeys.TypeOfTimer.rawValue + newIdentifier] = typeOfTimer.rawValue
            record![newIdentifier] = durationInSeconds
            let speeches = record![PlistKeys.Speeches.rawValue] as? [String]
            
            if let speeches = speeches {
                record![PlistKeys.Speeches.rawValue] = speeches + [newIdentifier]
            } else {
                record![PlistKeys.Speeches.rawValue] = [newIdentifier]
            }
        }
    }
    
    // FIXME: Consider renaming this to writeToDisk.
    func finish(name name: String) -> Bool {
        guard let dictionary = dictionary else {
            return false
        }
        
        guard name != "" && dictionary.count != 0 else {
            return false
        }
        
        let defaultManager = NSFileManager.defaultManager()
        if !defaultManager.fileExistsAtPath(FSKeys.folderPath) {
            try! defaultManager.createDirectoryAtPath(FSKeys.folderPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        return (dictionary as NSDictionary).writeToFile(FSKeys.pathForName(name), atomically: false)
    }
    
    // FIXME: Handle aprostophes!
    static func sanitizeIdentifier(identifier: String) -> String {
        let placeHolder = "z" + identifier.stringByReplacingOccurrencesOfString(" ", withString: "_")
        return placeHolder.stringByReplacingOccurrencesOfString("-", withString: "__")
    }
    
    static func desanitizeIdentifier(identifier: String) -> String {
        var string = identifier
        if let placeholder = identifier.rangeOfString("z") {
            string = identifier.stringByReplacingCharactersInRange(placeholder, withString: "")
        }
        let fire = string.stringByReplacingOccurrencesOfString("__", withString: "-")
        return fire.stringByReplacingOccurrencesOfString("_", withString: " ")
    }
}

enum TimerKind: String {
    case CountDownTimer
    case CountUpTimer
    case CountUpTimerReference
    case InfiniteTimer
    case OvertimeTimer
}

enum PlistKeys: String {
    case Speeches
    case TypeOfTimer
}

enum FSKeys: String {
    case Plist = ".plist"
    case FolderPath = "/Rounds/"
    
    static let folderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + FSKeys.FolderPath.rawValue
    static func pathForName(name: String) -> String {
        return folderPath + name + FSKeys.Plist.rawValue
    }
}

extension Round {
    static func roundForName(name: String) -> Round? {
        guard let dictionary = NSDictionary(contentsOfFile: FSKeys.pathForName(name)) where dictionary.count != 0 else {
            return nil
        }
        
        return roundFromDictionary(dictionary, name: name)
    }
    
    static func roundFromDictionary(dictionary: NSDictionary, name: String) -> Round {
        let names = dictionary[PlistKeys.Speeches.rawValue] as! [String]
        let numbers = names.map {
            dictionary[$0] as! Int
        }
        let typeOfTimers = names.map {
            dictionary[PlistKeys.TypeOfTimer.rawValue + $0] as! String
        }.map {
            TimerKind(rawValue: $0)!
        }
        let userNames = names.map {
            PlistCreator.desanitizeIdentifier($0)
        }
        
        return roundFromData(names: userNames, numbers: numbers, typeOfTimers: typeOfTimers, name: name)
    }
    
    static func roundFromData(names names: [String], numbers: [Int], typeOfTimers: [TimerKind], name: String) -> Round {
        var overtimeSegments = [OvertimeSegment?]()
        var countDownSegments = [CountDownSegment?]()
        var countUpSegments = [CountUpSegment?]()
        var infiniteSegments = [InfiniteSegment?]()
        var countUpSegmentReferences = [CountUpSegmentReference?]()
       
        zip(zip(typeOfTimers, numbers), names).forEach { kindAndDuration, name in
            let round = createTimersOfType(kindAndDuration.0, durationInSeconds: kindAndDuration.1, name: name)
            if let overtimeSegment = round.0 {
                overtimeSegments.append(overtimeSegment)
                countDownSegments.append(nil)
                countUpSegments.append(nil)
                infiniteSegments.append(nil)
                countUpSegmentReferences.append(nil)
            } else if let countDownSegment = round.1 {
                overtimeSegments.append(nil)
                countDownSegments.append(countDownSegment)
                countUpSegments.append(nil)
                infiniteSegments.append(nil)
                countUpSegmentReferences.append(nil)
            } else if let countUpSegment = round.2 {
                overtimeSegments.append(nil)
                countDownSegments.append(nil)
                countUpSegments.append(countUpSegment)
                infiniteSegments.append(nil)
                countUpSegmentReferences.append(nil)
            } else if let infiniteSegment = round.3 {
                overtimeSegments.append(nil)
                countDownSegments.append(nil)
                countUpSegments.append(nil)
                infiniteSegments.append(infiniteSegment)
                countUpSegmentReferences.append(nil)
            } else if let countUpSegmentReference = round.4 {
                overtimeSegments.append(nil)
                countDownSegments.append(nil)
                countUpSegments.append(nil)
                infiniteSegments.append(nil)
                countUpSegmentReferences.append(countUpSegmentReference)
            } else {
                fatalError()
            }
        }
        
        return Round(first: overtimeSegments, second: infiniteSegments, third: countUpSegments, fourth: countDownSegments, fifth: countUpSegmentReferences, name: name)
        
    }
    
    func delete() {
        let path = FSKeys.pathForName(name)
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.removeItemAtPath(path)
        Round.removeRoundNameToUpload(name)
        let database = CKContainer.defaultContainer().privateCloudDatabase
        let record = convertToCKRecord()
        database.deleteRecordWithID(record.recordID) { recordID, error in
            if (error != nil) {
                Round.addRoundNameToDelete(self.name)
            }
        }
    }
    
    private static func createTimersOfType(timerType: TimerKind, durationInMinutes: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?, CountUpSegmentReference?) {
        return Round.createTimersOfType(timerType, durationInSeconds: durationInMinutes * 60, name: name)
    }
    
    private static func createTimersOfType(timerType: TimerKind, durationInSeconds: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?, CountUpSegmentReference?) {
        switch timerType {
            case .OvertimeTimer:
                let segment = OvertimeSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds),  name: name)
                return (segment, nil, nil, nil, nil)
            case .InfiniteTimer:
                let infinteSegment = InfiniteSegment(sketch: TimerSketch(durationInSeconds: 0), name: name)
                return (nil, nil, nil, infinteSegment, nil)
            case .CountUpTimer:
                let segment = CountUpSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds), name: name)
                return (nil, nil, segment, nil, nil)
            case .CountDownTimer:
                let segment = CountDownSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds), name: name)
                return (nil, segment, nil, nil, nil)
            case .CountUpTimerReference:
                let segment = CountUpSegmentReference(sketch: TimerSketch(durationInSeconds: durationInSeconds), name: name)
            return (nil, nil, nil, nil, segment)
        }
    }
}
