//
//  PListCreator.swift
//  Timer
//
//  Created by E&Z Pierson on 9/8/15.
//  Copyright © 2015 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

class PlistCreator {
    var dictionary = [String: AnyObject]()
    
    func addTimer(ofType typeOfTimer: TimerKind, identifier: String, durationInMinutes: Int) {
        addTimer(ofType: typeOfTimer, identifier: identifier, durationInSeconds: durationInMinutes * 60)
    }
    
    func addTimer(ofType typeOfTimer: TimerKind, identifier: String, durationInSeconds: Int) {
        dictionary[PlistKeys.TypeOfTimer.rawValue + identifier] = typeOfTimer.rawValue
        dictionary[identifier] = durationInSeconds
        let speeches = dictionary[PlistKeys.Speeches.rawValue] as? [String]
        
        if let speeches = speeches {
            dictionary[PlistKeys.Speeches.rawValue] = speeches + [identifier]
        } else {
            dictionary[PlistKeys.Speeches.rawValue] = [identifier]
        }
    }
    
    func finish(name name: String) -> Bool {
        guard name != "" && dictionary.count != 0 else {
            return false
        }
        
        let defaultManager = NSFileManager.defaultManager()
        if !defaultManager.fileExistsAtPath(FSKeys.folderPath) {
            try! defaultManager.createDirectoryAtPath(FSKeys.folderPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        return (dictionary as NSDictionary).writeToFile(FSKeys.pathForName(name), atomically: false)
    }
}

enum TimerKind: String {
    case CountDownTimer
    case CountUpTimer
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
        guard let dictionary = NSDictionary(contentsOfFile: FSKeys.pathForName(name)) as? [String : AnyObject] where dictionary.count != 0 else {
            return nil
        }
        
        let names = dictionary[PlistKeys.Speeches.rawValue] as! [String]
        let numbers = names.map {
            dictionary[$0] as! Int
        }
        let typeOfTimers = names.map {
            dictionary[PlistKeys.TypeOfTimer.rawValue + $0] as! String
        }.map {
            TimerKind(rawValue: $0)!
        }

        var overtimeSegments = [OvertimeSegment?]()
        var countDownSegments = [CountDownSegment?]()
        var countUpSegments = [CountUpSegment?]()
        var infiniteSegments = [InfiniteSegment?]()
        
        zip(zip(typeOfTimers, numbers), names).forEach { kindAndDuration, name in
            let round = createTimersOfType(kindAndDuration.0, durationInSeconds: kindAndDuration.1, name: name)
            if let overtimeSegment = round.0 {
                overtimeSegments.append(overtimeSegment)
                countDownSegments.append(nil)
                countUpSegments.append(nil)
                infiniteSegments.append(nil)
            } else if let countDownSegment = round.1 {
                overtimeSegments.append(nil)
                countDownSegments.append(countDownSegment)
                countUpSegments.append(nil)
                infiniteSegments.append(nil)
            } else if let countUpSegment = round.2 {
                overtimeSegments.append(nil)
                countDownSegments.append(nil)
                countUpSegments.append(countUpSegment)
                infiniteSegments.append(nil)
            } else if let infiniteSegment = round.3 {
                overtimeSegments.append(nil)
                countDownSegments.append(nil)
                countUpSegments.append(nil)
                infiniteSegments.append(infiniteSegment)
            } else {
                fatalError()
            }
        }
        
        return Round(first: overtimeSegments, second: infiniteSegments, third: countUpSegments, fourth: countDownSegments, name: name)
    }
    
    func delete() {
        let path = FSKeys.pathForName(self.name)
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.removeItemAtPath(path)
    }
    
    private static func createTimersOfType(timerType: TimerKind, durationInMinutes: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?) {
        return Round.createTimersOfType(timerType, durationInMinutes: durationInMinutes * 60, name: name)
    }
    
    private static func createTimersOfType(timerType: TimerKind, durationInSeconds: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?) {
        switch timerType {
            case .OvertimeTimer:
                let segment = OvertimeSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds),  name: name)
                return (segment, nil, nil, nil)
            case .InfiniteTimer:
                let infinteSegment = InfiniteSegment(sketch: TimerSketch(durationInSeconds: 0), name: name)
                return (nil, nil, nil, infinteSegment)
            case .CountUpTimer:
                let segment = CountUpSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds), name: name)
                return (nil, nil, segment, nil)
            case .CountDownTimer:
                let segment = CountDownSegment(sketch: TimerSketch(durationInSeconds: durationInSeconds), name: name)
                return (nil, segment, nil, nil)
        }
    }
}
