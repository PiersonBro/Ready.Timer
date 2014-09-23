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
    case DurationOfRebuttalKey = "Duration of Rebuttal"
    case DurationOfConstructiveKey = "Duration of Constructive"
    case DurationOfCrossExaminationKey = "Duration of Cross Examination"
    //MARK: Lincoln Douglas
    case DurationOfACKey = "Duration of AC"
    case DurationOfNCKey = "Duration of NC"
    case DurationOf1ARKey = "Duration of 1 AR"
    case DurationOfNRKey = "Duration of NR"
    case DurationOf2ARKey = "Duration of 2 AR"
    
    static func durationKeyForSpeechName(speechName: NSString, debateType: DebateType) -> DurationKey {
        var durationOfSpeech: DurationKey? = nil
        switch debateType {
        case _, _, _:
            if speechName.containsString("C") && speechName.containsString("X") {
                durationOfSpeech = .DurationOfCrossExaminationKey
            } else {
                fallthrough
            }
        case .Parli, .TeamPolicy:
            if speechName.containsString("R") {
                durationOfSpeech = .DurationOfRebuttalKey
            } else if speechName.containsString("C") {
                durationOfSpeech = .DurationOfConstructiveKey
            }
        case .LincolnDouglas:
            if (DurationKey.DurationOfACKey.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfACKey
            } else if (DurationKey.DurationOfNCKey.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfNCKey
            } else if (DurationKey.DurationOf1ARKey.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOf1ARKey
            } else if (DurationKey.DurationOfNRKey.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOfNRKey
            } else if (DurationKey.DurationOf2ARKey.rawValue as NSString).containsString(speechName) {
                durationOfSpeech = .DurationOf2ARKey
            }
        }
        
        return durationOfSpeech!
    }
}

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
        let durationRaw: NSNumber? = debateRoundData[durationOfSpeechKey.rawValue] as? NSNumber
        let duration = (debateRoundData[durationOfSpeechKey.rawValue] as NSNumber).integerValue
        
        switch durationOfSpeechKey {
            case .DurationOfConstructiveKey:
                speechType = .Constructive(duration: duration)
            case .DurationOfRebuttalKey:
                speechType = .Rebuttal(duration: duration)
            case .DurationOfCrossExaminationKey:
                speechType = .CrossExamination(duration: duration)
            case .DurationOfACKey:
                speechType = .Constructive(duration: duration)
            case .DurationOfNCKey:
                speechType = .Constructive(duration: duration)
            case .DurationOf1ARKey:
                speechType = .Rebuttal(duration: duration)
            case .DurationOfNRKey:
                speechType = .Rebuttal(duration: duration)
            case .DurationOf2ARKey:
                speechType = .Rebuttal(duration: duration)
            
        }

        return speechType!
    }
}

struct Speech {
    let speechType: SpeechType
    let name: String
    var consumed: Bool
}

class DebateRoundManager {
    let debateType: DebateType
    private var speeches: [Speech]
    private let debateRoundData: [NSObject : AnyObject]
    let speechCount: Int
    
    init(type: DebateType) {
        debateType = type
        let path = NSBundle.mainBundle().pathForResource(PListKey.NameOfPlist.rawValue, ofType: "plist")
        let debates = NSDictionary(contentsOfFile: path!)
        let rawSpeechType = debateType.rawValue
        debateRoundData = debates![rawSpeechType] as [NSObject: AnyObject]
        speeches = DebateRoundManager.generateSpeechesFromData(debateRoundData, debateType: debateType)
        speechCount = speeches.count
    }

    private class func generateSpeechesFromData(debateRoundData: [NSObject: AnyObject], debateType: DebateType) -> [Speech] {
        let stringOfSpeeches: [String] = (debateRoundData[PListKey.Speeches.rawValue] as NSArray) as [String]
        var speeches: [Speech] = []
       
        for speechName: String in stringOfSpeeches {
            let speechType = SpeechType.typeOfSpeech(speechName, debateRoundData: debateRoundData, debateType: debateType)
            let newSpeech = Speech(speechType: speechType, name: speechName, consumed: false)
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
