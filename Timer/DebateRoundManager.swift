//
//  DebateRoundManager.swift
//  Timer
//
//  Created by E&Z Pierson on 8/26/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation

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
        switch debateType {
        case _, _, _:
            if speechName.containsString("C") && speechName.containsString("X") {
                durationOfSpeech = .DurationOfCrossExamination
            } else {
                fallthrough
            }
        case .Parli, .TeamPolicy:
            if speechName.containsString("R") {
                durationOfSpeech = .DurationOfRebuttal
            } else if speechName.containsString("C") {
                durationOfSpeech = .DurationOfConstructive
            }
        case .LincolnDouglas:
            if (DurationKey.DurationOfAC.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfAC
            } else if (DurationKey.DurationOfNC.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfNC
            } else if (DurationKey.DurationOf1AR.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOf1AR
            } else if (DurationKey.DurationOfNR.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfNR
            } else if (DurationKey.DurationOf2AR.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOf2AR
            }
        }
        
        return durationOfSpeech!
    }
}
// FIXME: Refator too hard to use.
private enum PListKey: String {
    case NameOfPlist = "DebateType"
    case Speeches = "Speeches"
    case TotalPrepTime = "Total Prep Time"
}

enum SpeechType: Printable {
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
    
    private static func typeOfSpeech(nameOfSpeech: NSString, debateRoundData: [NSObject: AnyObject], debateType: DebateType) -> SpeechType {
        var speechType: SpeechType? = nil
        var durationOfSpeechKey = DurationKey.durationKeyForSpeechName(nameOfSpeech, debateType: debateType)
        let duration = (debateRoundData[durationOfSpeechKey.rawValue] as NSNumber).integerValue
        
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

struct Speech {
    let speechType: SpeechType
    let name: String
    var timerController: TimerController
    var consumed: Bool = false
    
    init(speechType: SpeechType, name: String) {
       self.name = name
       self.speechType = speechType
       timerController = TimerController(durationInMinutes: NSTimeInterval(speechType.durationOfSpeech()))
    }
}

extension Speech: Printable {
    var description: String {
        return "Name: \(name) \n SpeechType: \(speechType) \n timer controller \(timerController) \n consumed: \(consumed)"
    }
}

class DebateRoundManager {
    let debateType: DebateType
    let speechCount: Int
    let affPrepTime: CountUpTimerController
    let negPrepTime: CountUpTimerController
    
    private var speeches: [Speech]
    private let debateRoundData: [NSObject : AnyObject]
    
    init(type: DebateType) {
        debateType = type
        let path = NSBundle.mainBundle().pathForResource(PListKey.NameOfPlist.rawValue, ofType: "plist")
        let debates = NSDictionary(contentsOfFile: path!)!
        debateRoundData = debates[debateType.rawValue] as [NSObject: AnyObject]
        speeches = DebateRoundManager.generateSpeechesFromData(debateRoundData, debateType: debateType)
        speechCount = speeches.count
        let prepTimeDuration = (debateRoundData[PListKey.TotalPrepTime.rawValue] as NSNumber).doubleValue
        
        affPrepTime = CountUpTimerController(upperLimitInMinutes: prepTimeDuration)
        negPrepTime = CountUpTimerController(upperLimitInMinutes: prepTimeDuration)
    }

    private class func generateSpeechesFromData(debateRoundData: [NSObject: AnyObject], debateType: DebateType) -> [Speech] {
        let stringOfSpeeches = debateRoundData[PListKey.Speeches.rawValue] as [String]
        var speeches: [Speech] = []

        for speechName: String in stringOfSpeeches {
            let speechType = SpeechType.typeOfSpeech(speechName, debateRoundData: debateRoundData, debateType: debateType)
            let newSpeech = Speech(speechType: speechType, name: speechName)
            speeches.append(newSpeech)
        }
        
        return speeches
    }
    
    func getSpeechAtIndex(index: Int) -> Speech {
        return speeches[index]
    }
    
    func markSpeechAsConsumedAtIndex(index: Int) {
        speeches[index].consumed = true
    }
}
