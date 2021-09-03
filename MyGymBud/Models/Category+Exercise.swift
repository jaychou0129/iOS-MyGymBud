//
//  Category.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/6/21.
//

import SwiftUI

struct Category: Identifiable, Codable {
    
    let id: UUID
    var name: String
    var exercises: [Exercise]
    var enabled: Bool
    var color: Color
    
    init (id: UUID = UUID(), name: String = "", exercises: [Exercise] = [], enabled: Bool = true, color: Color = .random) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.enabled = enabled
        self.color = color
    }
    
    static var sampleData: [Category] {
        [
            Category(name: "Chest", exercises: [Exercise(name: "TEST", defaultWeight: Weight(25, Weight.Unit.KG), defaultReps: 12, defaultRestTime: Time(minutes: 2), maxWeightLog: WeightLog(weight: Weight(30, Weight.Unit.KG), reps: [Repetition(reps: 12, sets: 4)]), maxDate: Date(), notes: "NOTESESESES", tags: ["one", "two", "three"]), Exercise(name: "TESTTIME", mode: Mode.Timed, defaultTime: Time(seconds: 30), maxTimedLog: TimedLog(time: Time(minutes: 1), sets: 1), maxDate: Date()), Exercise(name: "TESTROUTINE", mode: Mode.Routine), Exercise(name: "Dumbbell Chest Press", maxWeightLog: WeightLog(weight: Weight(25, Weight.Unit.KG), reps: [Repetition(reps: 15, sets: 1)]), maxDate: Date()),Exercise(name: "Stationary Chest Press")], color: Color("Chest")),
            Category(name: "Abdominals", exercises: [Exercise(name: "Russian Twist")], color: Color("Abdominals")),
            Category(name: "Arms", exercises: [Exercise(name: "Dumbbell Bicep Curls"), Exercise(name: "Dumbbell Tricep Extensions"), Exercise(name: "Stationary Tricep Pushdowns")], color: Color("Arms"))
        ]
    }
    
    struct Data: Hashable {
        var name: String = ""
        var enabled: Bool = true
        var color: Color = .random
    }
    
    var data: Data {
        return Data(name: name, enabled: enabled, color: color)
    }
    
    mutating func update(from data: Data) {
        name = data.name
        enabled = data.enabled
        color = data.color
    }
}

struct Exercise: Identifiable, Codable, Comparable {
    let id: UUID
    var name: String
    var enabled: Bool
    var mode: Mode
    var defaultWeight: Weight
    var defaultTime: Time
    var defaultReps: Int
    var defaultRestTime: Time
    var maxWeightLog: WeightLog? = nil
    var maxTimedLog: TimedLog? = nil
    var maxDate: Date? = nil
    var notes: String
    var tags: [String]
    
    var maxExists: Bool {
        switch mode {
        case Mode.Weight:
            return maxWeightLog != nil && maxDate != nil
        case Mode.Timed:
            return maxTimedLog != nil && maxDate != nil
            
        // for Mode.Routine or any other case
        default:
            return false
        }
    }
    
    init (id: UUID = UUID(), name: String = "", enabled: Bool = true, mode: Mode = Mode.Weight, defaultWeight: Weight = Weight(), defaultTime: Time = Time(), defaultReps: Int = 1, defaultRestTime: Time = Time(), maxWeightLog: WeightLog? = nil, maxTimedLog: TimedLog? = nil, maxDate: Date? = nil, notes: String = "", tags: [String] = []) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.mode = mode
        self.defaultWeight = defaultWeight
        self.defaultTime = defaultTime
        self.defaultReps = defaultReps
        self.defaultRestTime = defaultRestTime
        self.maxWeightLog = maxWeightLog
        self.maxTimedLog = maxTimedLog
        self.maxDate = maxDate
        self.notes = notes
        self.tags = tags
    }
    
    init (from data: Data) {
        self.id = UUID()
        self.name = data.name
        self.enabled = data.enabled
        self.mode = data.mode
        self.defaultWeight = data.defaultWeight
        self.defaultTime = data.defaultTime
        self.defaultReps = data.defaultReps
        self.defaultRestTime = data.defaultRestTime
        self.notes = data.notes
        self.tags = data.tags
    }
    
    struct Data: Equatable {
        var name: String = ""
        var enabled: Bool = true
        var mode: Mode = Mode.Weight
        var defaultWeight: Weight = Weight()
        var defaultTime: Time = Time()
        var defaultReps: Int = 1
        var defaultRestTime: Time = Time()
        var notes: String = ""
        var tags: [String] = []
    }
    
    var data: Data {
        return Data(name: name, enabled: enabled, mode: mode, defaultWeight: defaultWeight, defaultTime: defaultTime, defaultReps: defaultReps, defaultRestTime: defaultRestTime, notes: notes, tags: tags)
    }
    
    mutating func update(from data: Data) {
        name = data.name
        enabled = data.enabled
        mode = data.mode
        defaultWeight = data.defaultWeight
        defaultTime = data.defaultTime
        defaultReps = data.defaultReps
        defaultRestTime = data.defaultRestTime
        notes = data.notes
        tags = data.tags
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        if lhs.enabled != lhs.enabled {
            return lhs.enabled && !rhs.enabled
        } else {
            return lhs.name < rhs.name
        }
    }
}

extension Array where Element == Exercise {
    // can only be used for immutable operations
    func find(eID: UUID) -> Exercise? {
        return self.first(where: {$0.id == eID})
    }
}

enum Mode: Int, Codable {
    case Timed
    case Weight
    case Routine
    
    func disp() -> String {
        switch self {
        case Mode.Timed:
            return "Timed"
        case Mode.Weight:
            return "Weight"
        default:
            return "Routine"
        }
    }
    
    init(from modeName: String) {
        switch modeName.lowercased() {
        case "timed":
            self = .Timed
        case "weight":
            self = .Weight
        default:
            self = .Routine
        }
    }
}
