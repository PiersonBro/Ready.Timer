//
//  CloudKit+Round.swift
//  Timer
//
//  Created by EandZ on 1/26/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import Foundation
import CloudKit

struct CloudKitString {
    static let roundDataType = "RoundDataType"
    static let name = "name"
}

extension Round {
    
    static func updateFromCloudKit() {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CloudKitString.roundDataType, predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { data, error in
            if let data = data, error == nil && data != [] {
                let rounds = allRounds()
                let roundsFromRecords = data.map { roundFromRecord($0) }
                let cloudRounds = Set(roundsFromRecords).subtracting(rounds)
                let roundsToUpload = roundNamesToUpload().map { roundForName($0)! }
                let roundsToDelete = zip(cloudRounds, roundNamesToDelete()).filter { $0.name == $1 }.map { $0.0 }
                let roundsToAdd = cloudRounds.subtracting(roundsToDelete)
                let modifyRecordsOperation = modifyRounds(toDelete: Array(roundsToDelete), toAdd: Array(roundsToUpload))
                
                modifyRecordsOperation.modifyRecordsCompletionBlock = { added, deleted, error in
                    roundsToUpload.forEach {
                        removeRoundNameToUpload($0.name)
                    }
                    roundsToDelete.forEach {
                        removeRoundNameToDelete($0.name)
                    }
                }
                modifyRecordsOperation.start()
                
                roundsToAdd.forEach {
                    $0.writeToDisk()
                }
            } else if let data = data, error == nil && data == [] {
                let hardwareRounds = Set(allRounds()).subtracting([])
                let modifyRecordsOperation = modifyRounds(toDelete: nil, toAdd: Array(hardwareRounds))

                modifyRecordsOperation.perRecordProgressBlock = { record, time in
                    let name = record["name"] as! String
                    removeRoundNameToUpload(name)
                    print(name, time)
                }
                modifyRecordsOperation.perRecordCompletionBlock = { record, error in
                    print("Error is: ", error)
                }
                modifyRecordsOperation.start()
            } else {
                print(error)
            }
        }
    }
    
    static func roundFromRecord(_ record: CKRecord) -> Round {
        let name = PlistCreator.desanitizeIdentifier(record[CloudKitString.name] as! String)
        let recordNames = record[PlistKeys.Speeches.rawValue] as! [String]
        let numbers = recordNames.map {
            record[$0] as! Int
        }

        let typeOfTimers = recordNames.map {
            record[PlistKeys.TypeOfTimer.rawValue + $0] as! String
        }.map {
            TimerKind(rawValue: $0)!
        }
        let names = recordNames.map { name in
            PlistCreator.desanitizeIdentifier(name)
        }
        
        return roundFromData(names: names, numbers: numbers, typeOfTimers: typeOfTimers, name: name)
    }
    
    static func modifyRounds(toDelete delete: [Round]?, toAdd add: [Round]?) -> CKModifyRecordsOperation {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let deleteRecords = delete?.map { $0.convertToCKRecord() }
        let addRecords = add?.map { $0.convertToCKRecord() }
        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: addRecords, recordIDsToDelete: deleteRecords?.map { $0.recordID })
        
        modifyRecordsOperation.database = privateDatabase
        return modifyRecordsOperation
    }
    
    enum CloudError {
        case unkown
        case noInternet
    }
    
    func uploadToCloudKit(errorBlock: (error: CloudError) -> ()) {
        let record = convertToCKRecord()
        let privateDatabase = CKContainer.default().privateCloudDatabase
        privateDatabase.save(record) { record, error in
            if let error = (error as? NSError) {
                if error.code == 3 {
                    errorBlock(error: .noInternet)
                } else {
                    errorBlock(error: .unkown)
                }
            }
        }
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CloudKitString.roundDataType)
        let segmentValues = segmentProxies.map { segmentProxy -> (name: String, kind: TimerKind, durationInSeconds: Int?, durationInMinutes: Int?) in
            if let segmentProxy = segmentProxy {
                if let overtimeSegment = segmentProxy.segments.0 {
                    return (name: overtimeSegment.name, kind: .OvertimeTimer, durationInSeconds: overtimeSegment.sketch.durationInSeconds, durationInMinutes: overtimeSegment.sketch.durationInMinutes)
                } else if let infiniteSegment = segmentProxy.segments.1 {
                    return (name: infiniteSegment.name, kind: .InfiniteTimer, durationInSeconds: infiniteSegment.sketch.durationInSeconds, durationInMinutes: infiniteSegment.sketch.durationInMinutes)
                } else if let countUpSegment = segmentProxy.segments.2 {
                    return (name: countUpSegment.name, kind: .CountUpTimer, durationInSeconds: countUpSegment.sketch.durationInSeconds, durationInMinutes: countUpSegment.sketch.durationInMinutes)
                } else if let countDownSegment = segmentProxy.segments.3 {
                    return (name: countDownSegment.name, kind: .CountDownTimer, durationInSeconds: countDownSegment.sketch.durationInSeconds, durationInMinutes: countDownSegment.sketch.durationInMinutes)
                } else if let countUpSegmentReference = segmentProxy.segments.4 {
                    return (name: countUpSegmentReference.name, kind: .CountUpTimerReference, durationInSeconds: countUpSegmentReference.sketch.durationInSeconds, durationInMinutes: countUpSegmentReference.sketch.durationInMinutes)
                } else {
                    fatalError()
                }
            } else {
                fatalError()
            }
        }
        
        let plistCreator = PlistCreator(record: record)
        segmentValues.forEach { segmentValue in
            let durationInSeconds = segmentValue.durationInSeconds ?? (segmentValue.durationInMinutes! * 60)
            plistCreator.addTimer(ofType: segmentValue.kind, identifier: segmentValue.name, durationInSeconds: durationInSeconds)
        }
        
        record[CloudKitString.name] = name
        return record
    }
    
    // FIXME: Consider consolidating this logic with PListCreator.finish(name:)
    func writeToDisk() {
        let plistCreator = PlistCreator()
        self.segmentProxies.forEach { segmentProxy in
            if let segmentProxy = segmentProxy {
                if let durationInMinutes = segmentProxy.sketch.durationInMinutes {
                    plistCreator.addTimer(ofType: segmentProxy.kind , identifier: segmentProxy.name, durationInMinutes: durationInMinutes)
                } else {
                    plistCreator.addTimer(ofType: segmentProxy.kind, identifier: segmentProxy.name, durationInSeconds: segmentProxy.sketch.durationInSeconds!)
                }
            }
        }
        plistCreator.finish(name: name)
    }
}
