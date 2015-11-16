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
        
    //NOTE: `duration` is in minutes.
    func addTimer(ofType typeOfTimer: TimerKind, identifier: String, duration: Int) {
        dictionary[PlistKeys.TypeOfTimer.rawValue + identifier] = typeOfTimer.rawValue
        dictionary[identifier] = duration
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
        let path = NSBundle.mainBundle().resourcePath! + "/" + name + ".plist"
        return (dictionary as NSDictionary).writeToFile(path, atomically: false)
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

extension Round {
    static func roundForName(name: String) -> Round {
        let path = NSBundle.mainBundle().resourcePath! + "/" + name + ".plist"
        let dictionary = NSDictionary(contentsOfFile: path)! as! [String : AnyObject]
        let names = dictionary[PlistKeys.Speeches.rawValue] as! [String]
        let numbers = names.map {
            dictionary[$0] as! Int
        }
        
        let duration = zip(numbers, names).reduce([String: Int]()) { (var dictionary, numberAndName) in
            dictionary[numberAndName.1] = numberAndName.0
            return dictionary
        }
        
        let typeOfTimers = names.map {
            dictionary[PlistKeys.TypeOfTimer.rawValue + $0] as! String
        }.map {
            TimerKind(rawValue: $0)!
        }
        
        let allKeys = duration.map { $0.1 }

        var overtimeSegments = [OvertimeSegment?]()
        var countDownSegments = [CountDownSegment?]()
        var countUpSegments = [CountUpSegment?]()
        var infiniteSegments = [InfiniteSegment?]()
        
        zip(zip(typeOfTimers, allKeys), names).forEach { kindAndDuration, name in
            let round = createTimersOfType(kindAndDuration.0, duration: kindAndDuration.1, name: name)
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
        
        return Round(first: overtimeSegments, second: infiniteSegments, third: countUpSegments, fourth: countDownSegments)
    }
    
    private static func createTimersOfType(timerType: TimerKind, duration: Int, name: String) -> (OvertimeSegment?, CountDownSegment?,  CountUpSegment?, InfiniteSegment?) {
        switch timerType {
            case .OvertimeTimer:
                let segment = OvertimeSegment(timer: OvertimeTimer(timeLimitInMinutes: duration),  name: name)
                return (segment, nil, nil, nil)
            case .InfiniteTimer:
                let infinteSegment = InfiniteSegment(timer: Timer(blueprint: InfiniteBlueprint()), name: name)
                return (nil, nil, nil, infinteSegment)
            case .CountUpTimer:
                let timer = Timer(blueprint: CountUpBlueprint(upperLimitInMinutes: duration))
                let segment = CountUpSegment(timer: timer, name: name)
                return (nil, nil, segment, nil)
            case .CountDownTimer:
                let timer = Timer(blueprint: CountDownBlueprint(countDownFromInMinutes: duration))
                let segment = CountDownSegment(timer: timer, name: name)
                return (nil, segment, nil, nil)
        }
    }
}
