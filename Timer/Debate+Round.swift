//
//  Debate+Round.swift
//  Timer
//
//  Created by E&Z Pierson on 8/26/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

import Foundation
import TimerKit

enum DebateType: String {
    case Parli, TeamPolicy, LincolnDouglas
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

private extension OvertimeSegment {
    init(speechType: SpeechType, name: String) {
        self.name = name
        sketch = TimerSketch(durationInMinutes: speechType.durationOfSpeech())
    }
}

extension Round {
    static func roundFromDebateType(type: DebateType) -> Round {
        let path = NSBundle.mainBundle().pathForResource(PListKey.DebugNameOfPlist.rawValue, ofType: "plist")
        let debates = NSDictionary(contentsOfFile: path!)!
        let debateRoundData = debates[type.rawValue] as! [NSObject: AnyObject]
        let prepTimeDuration = debateRoundData[PListKey.TotalPrepTime.rawValue] as! Int

        let timers = generateSpeechesFromData(debateRoundData, debateType: type, prepTime: prepTimeDuration) { segment -> Bool in
                if segment.name == "CX" {
                    return true
                } else {
                    return isRebuttal(segment)
                }
        }
        
        return Round(first: timers.0, fifth: timers.1, name: type.rawValue)
    }
}

private func isRebuttal(x: OvertimeSegment) -> Bool {
    if x.name == "1 AR" {
        return true
    } else if x.name == "1 NR" || x.name == "NR" {
        return true
    } else if x.name == "2 NR" {
        return true
    } else {
        return false
    }
}

private func generateSpeechesFromData(debateRoundData: [NSObject: AnyObject], debateType: DebateType, prepTime: Int, shouldIntersperseAfterSegment: (overtimeSegment: OvertimeSegment) -> Bool) -> ([OvertimeSegment?], [CountUpSegmentReference?])  {
    let stringOfSpeeches = debateRoundData[PListKey.Speeches.rawValue] as! [String]
    let segments = stringOfSpeeches.map { speechName -> OvertimeSegment in
        let speechType = SpeechType.typeOfSpeech(speechName, debateRoundData: debateRoundData, debateType: debateType)
        return OvertimeSegment(speechType: speechType, name: speechName)
    }
    
    var classySegments = segments.map { segment -> Box<OvertimeSegment>? in
        Box(value: segment)
    }
    
    classySegments.filter {
        shouldIntersperseAfterSegment(overtimeSegment: $0!.value)
    }.forEach { box in
        let index = classySegments.indexOf { $0 == box}
        classySegments.insert(nil, atIndex: index! + 1)
    }
    
    let leftSegment = CountUpSegmentReference(sketch: TimerSketch(durationInMinutes: prepTime), name: "Aff Prep Timer")
    let rightSegment = CountUpSegmentReference(sketch: TimerSketch(durationInMinutes: prepTime), name: "Neg Prep Timer")
    var left = false
    let countUpSegment = classySegments.map { segment -> CountUpSegmentReference? in
        if let _ = segment {
            return nil
        } else {
            if left {
                left = false
                return leftSegment
            } else {
                left = true
                return rightSegment
            }
        }
    }
    let finalSegments = classySegments.map { $0?.value}
    
    return (finalSegments, countUpSegment)
}


private class Box<T: Equatable> {
    let value: T
    
    init(value: T) {
        self.value = value
    }
}

extension Box: Equatable {}

private func ==<T: Equatable>(lhs: Box<T>, rhs:Box<T>) -> Bool {
    return lhs.value == rhs.value && ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
