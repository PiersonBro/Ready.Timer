//
//  DebateRoundManager.swift
//  Timer
//
//  Created by E&Z Pierson on 8/26/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

enum DebateType: String {
    case Parli = "Parli"
    case TeamPolicy = "TeamPolicy"
    case LincolnDouglas = "LincolnDouglas"
}

private enum DurationKey: String {
    case DurationOfRebuttal = "Duration of Rebuttal"
    case DurationOfConstructive = "Duration of Constructive"
    case DurationOfCrossExamination = "Duration of Cross Examination"
    //MARK: Lincoln Douglas
    case DurationOfAC = "Duration of AC"
    case DurationOfNC = "Duration of NC"
    case DurationOf1AR = "Duration of 1 AR"
    case DurationOfNR = "Duration of NR"
    case DurationOf2AR = "Duration of 2 AR"
    
    static func durationKeyForSpeechName(speechName: NSString, debateType: DebateType) -> DurationKey {
        var durationOfSpeech: DurationKey? = nil

        if speechName.containsString("C") && speechName.containsString("X") {
            durationOfSpeech = .DurationOfCrossExamination
        } else {
            switch debateType {
            case .Parli, .TeamPolicy:
                if speechName.containsString("R") {
                    durationOfSpeech = .DurationOfRebuttal
                } else if speechName.containsString("C") {
                    durationOfSpeech = .DurationOfConstructive
                }
            case .LincolnDouglas:
                if (DurationKey.DurationOfAC.rawValue as NSString).containsString(speechName as String) {
                    durationOfSpeech = .DurationOfAC
                } else if (DurationKey.DurationOfNC.rawValue as NSString).containsString(speechName as String) {
                    durationOfSpeech = .DurationOfNC
                } else if (DurationKey.DurationOf1AR.rawValue as NSString).containsString(speechName as String) {
                    durationOfSpeech = .DurationOf1AR
                } else if (DurationKey.DurationOfNR.rawValue as NSString).containsString(speechName as String) {
                    durationOfSpeech = .DurationOfNR
                } else if (DurationKey.DurationOf2AR.rawValue as NSString).containsString(speechName as String) {
                    durationOfSpeech = .DurationOf2AR
                }
            }
        }
        
        return durationOfSpeech!
    }
}

// FIXME: Refactor too hard to use.
private enum PListKey: String {
    case NameOfPlist = "DebateType"
    case DebugNameOfPlist = "DebateType-copy"
    case Speeches = "Speeches"
    case TotalPrepTime = "Total Prep Time"
}

enum SpeechType {
    case Constructive(duration: Int)
    case Rebuttal(duration: Int)
    case CrossExamination(duration: Int)
    
    func durationOfSpeech() -> Int {
        var durationOfSpeech = 0
        switch self {
            case .Constructive(let duration):
                durationOfSpeech = duration
            case .Rebuttal(let duration):
                durationOfSpeech = duration
            case .CrossExamination(let duration):
                durationOfSpeech = duration
        }
        
        return durationOfSpeech
    }
    
    private static func typeOfSpeech(nameOfSpeech: NSString, debateRoundData: [NSObject: AnyObject], debateType: DebateType) -> SpeechType {
        var speechType: SpeechType? = nil
        let durationOfSpeechKey = DurationKey.durationKeyForSpeechName(nameOfSpeech, debateType: debateType)
        let duration = (debateRoundData[durationOfSpeechKey.rawValue] as! NSNumber).integerValue
        
        switch durationOfSpeechKey {
            case .DurationOfConstructive:
                speechType = .Constructive(duration: duration)
            case .DurationOfRebuttal:
                speechType = .Rebuttal(duration: duration)
            case .DurationOfCrossExamination:
                speechType = .CrossExamination(duration: duration)
            case .DurationOfAC:
                speechType = .Constructive(duration: duration)
            case .DurationOfNC:
                speechType = .Constructive(duration: duration)
            case .DurationOf1AR:
                speechType = .Rebuttal(duration: duration)
            case .DurationOfNR:
                speechType = .Rebuttal(duration: duration)
            case .DurationOf2AR:
                speechType = .Rebuttal(duration: duration)
        }

        return speechType!
    }
}

extension SpeechType: CustomStringConvertible {
    var description: String {
        switch self {
        case .Constructive(let duration):
            return "Speech is of Type: Constructive it's duration is \(duration)"
        case .Rebuttal(let duration):
            return "Speech is of Type: Rebuttal it's duration is \(duration)"
        case .CrossExamination(let duration):
            return "Speech is of Type: Cross Examination it's duration is \(duration)"
        }
    }
}

struct Speech {
    let speechType: SpeechType
    let name: String
    let overtimeTimer: OvertimeTimer
    
    init(speechType: SpeechType, name: String) {
        self.name = name
        self.speechType = speechType
        let duration = NSTimeInterval(speechType.durationOfSpeech() * 60)
        overtimeTimer = OvertimeTimer(timeLimit: duration)
    }
}

extension Speech: CustomStringConvertible {
    var description: String {
        return "Name: \(name) \n SpeechType: \(speechType) \n timer controller \(overtimeTimer)"
    }
}

class DebateRoundManager {
    let debateType: DebateType
    let speechCount: Int
    let affPrepTime: Timer<CountUpBlueprint>
    let negPrepTime: Timer<CountUpBlueprint>
    
    let speeches: [Speech]
    private let debateRoundData: [NSObject : AnyObject]
    
    init(type: DebateType) {
        debateType = type
        let path = NSBundle.mainBundle().pathForResource(PListKey.DebugNameOfPlist.rawValue, ofType: "plist")
        let debates = NSDictionary(contentsOfFile: path!)!
        debateRoundData = debates[debateType.rawValue] as! [NSObject: AnyObject]
        speeches = DebateRoundManager.generateSpeechesFromData(debateRoundData, debateType: debateType)
        speechCount = speeches.count

        let prepTimeDuration = (debateRoundData[PListKey.TotalPrepTime.rawValue] as! NSNumber).doubleValue * 60.0
        let prepBlueprint = CountUpBlueprint(upperLimit: prepTimeDuration)
        
        affPrepTime = Timer(blueprint: prepBlueprint)
        negPrepTime = Timer(blueprint: prepBlueprint)
    }

    private class func generateSpeechesFromData(debateRoundData: [NSObject: AnyObject], debateType: DebateType) -> [Speech] {
        let stringOfSpeeches = debateRoundData[PListKey.Speeches.rawValue] as! [String]
      
        let speeches = stringOfSpeeches.map { (speechName: String) -> Speech in
            let speechType = SpeechType.typeOfSpeech(speechName, debateRoundData: debateRoundData, debateType: debateType)
        
            return Speech(speechType: speechType, name: speechName)
        }
        
        return speeches
    }
}
