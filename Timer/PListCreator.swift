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
        //FIXME: Use an enum
        let speeches = dictionary[PlistKeys.Speeches.rawValue] as? [String]
        
        if var speches = speeches {
            speches.append(identifier)
            dictionary[PlistKeys.Speeches.rawValue] = speches
        } else {
            dictionary[PlistKeys.Speeches.rawValue] = [identifier]
        }
    }
    
    func finish(name name: String) -> Bool {
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
    static func roundForName(name: String) -> Round {
        let dictionary = NSDictionary(contentsOfFile: FSKeys.pathForName(name))! as! [String : AnyObject]
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
    
    private static func createTimersOfType(timerType: TimerKind, durationInMinutes: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?) {
        return Round.createTimersOfType(timerType, durationInMinutes: durationInMinutes * 60, name: name)
    }
    
    private static func createTimersOfType(timerType: TimerKind, durationInSeconds: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?) {
        switch timerType {
            case .OvertimeTimer:
                let segment = OvertimeSegment(timer: OvertimeTimer(timeLimitInSeconds: durationInSeconds),  name: name)
                return (segment, nil, nil, nil)
            case .InfiniteTimer:
                let infinteSegment = InfiniteSegment(timer: Timer(blueprint: InfiniteBlueprint()), name: name)
                return (nil, nil, nil, infinteSegment)
            case .CountUpTimer:
                let timer = Timer(blueprint: CountUpBlueprint(upperLimitInSeconds: durationInSeconds))
                let segment = CountUpSegment(timer: timer, name: name)
                return (nil, nil, segment, nil)
            case .CountDownTimer:
                let timer = Timer(blueprint: CountDownBlueprint(countDownFromInSeconds: durationInSeconds))
                let segment = CountDownSegment(timer: timer, name: name)
                return (nil, segment, nil, nil)
        }
    }
}
