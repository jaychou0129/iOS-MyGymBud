//
//  Log.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/30/21.
//

import Foundation

struct Log: Identifiable, Codable, Comparable, Hashable {
    let id: UUID
    var date: Date
    var eID: UUID
    var weightLogs: [WeightLog]
    var timedLogs: [TimedLog]
    var routineLogs: Int
    var notes: String
    
    var maxWeightLog: WeightLog? {
        var maximum: WeightLog? = nil
        for log in self.weightLogs {
            if maximum == nil || log.weight >= maximum!.weight {
                maximum = log
            }
        }
        return maximum
    }
    
    var maxTimedLog: TimedLog? {
        var maximum: TimedLog? = nil
        for log in self.timedLogs {
            if maximum == nil || log.time >= maximum!.time {
                maximum = log
            }
        }
        return maximum
    }
    
    var weightVolume: Weight {
        var vol: Weight = Weight()
        for log in self.weightLogs {
            for rep in log.reps {
                vol += (log.weight * rep.reps * rep.sets)
            }
        }
        return vol
    }
    
    var timedVolume: Time {
        var vol: Time = Time()
        for log in self.timedLogs {
            vol += (log.time * log.sets)
        }
        return vol
    }
    
    struct Data: Hashable {
        var date: Date = Date()
        var eID: UUID = UUID()
        var weightLogs: [WeightLog] = []
        var timedLogs: [TimedLog] = []
        var routineLogs: Int = 1
        var notes: String = ""
    }
    
    var data: Data {
        return Data(date: date, eID: eID, weightLogs: weightLogs, timedLogs: timedLogs, routineLogs: routineLogs, notes: notes)
    }
    
    mutating func update(from data: Data) {
        date = data.date
        eID = data.eID
        weightLogs = data.weightLogs
        timedLogs = data.timedLogs
        routineLogs = data.routineLogs
        notes = data.notes
    }
    
    static func build(from data: Data) -> Log {
        return Log(date: data.date, eID: data.eID, weightLogs: data.weightLogs, timedLogs: data.timedLogs, routineLogs: data.routineLogs, notes: data.notes)
    }
    
    init(date: Date = Date(), eID: UUID = UUID(), weightLogs: [WeightLog] = [], timedLogs: [TimedLog] = [], routineLogs: Int = 0, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.eID = eID
        self.weightLogs = weightLogs
        self.timedLogs = timedLogs
        self.routineLogs = routineLogs
        self.notes = notes
    }
    
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Log, rhs: Log) -> Bool {
        return lhs.date < rhs.date
    }
}

struct Repetition: Codable, Hashable, Comparable {
    var reps: Int
    var sets: Int
    
    func disp() -> String {
        return " × \(reps) × \(sets)"
    }
    
    static func < (lhs: Repetition, rhs: Repetition) -> Bool {
        return (lhs.reps == rhs.reps) ? (lhs.sets < rhs.sets) : (lhs.reps < rhs.reps)
    }
}

struct TimedLog: Codable, Hashable, Comparable {
    var time: Time
    var sets: Int
    
    func disp() -> String {
        return "\(time.dispText()) × \(sets)"
    }
    
    static func < (lhs: TimedLog, rhs: TimedLog) -> Bool {
        if lhs.time == rhs.time {
            return lhs.sets < rhs.sets
        }
        return lhs.time < rhs.time
    }
}

struct WeightLog: Codable, Hashable, Comparable {
    var weight: Weight
    var reps: [Repetition]
    
    static func < (lhs: WeightLog, rhs: WeightLog) -> Bool {
        if lhs.weight == rhs.weight {
            return lhs.reps.sorted().last! < rhs.reps.sorted().last!
        }
        
        return lhs.weight < rhs.weight
    }
}
