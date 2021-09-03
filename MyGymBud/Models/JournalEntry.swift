//
//  JournalEntry.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/31/21.
//

import Foundation

struct JournalEntry: Identifiable, Codable, Comparable, Hashable {

    let id: UUID
    var date: Date
    var bodyWeight: Weight?
    var bodyFatPercentage: Double?
    var bmr: Int?
    var bmi: Double?
    var skeMuscleMass: Weight?
    var totalCalories: Int?
    var carbohydrateGrams: Double?
    var proteinGrams: Double?
    var fatGrams: Double?
    var notes: String
    
    struct Data {
        var date: Date = Date()
        var bodyWeight: Weight? = nil
        var bodyFatPercentage: String = ""
        var bmr: String = ""
        var bmi: String = ""
        var skeMuscleMass: Weight? = nil
        var totalCalories: String = ""
        var carbohydrateGrams: String = ""
        var proteinGrams: String = ""
        var fatGrams: String = ""
        var notes: String = ""
    }
    
    var data: Data {
        return Data(date: date, bodyWeight: bodyWeight, bodyFatPercentage: bodyFatPercentage?.removeTrailingZeros() ?? "", bmr: bmr?.toString() ?? "", bmi: bmi?.removeTrailingZeros() ?? "", skeMuscleMass: skeMuscleMass, totalCalories: totalCalories?.toString() ?? "", carbohydrateGrams: carbohydrateGrams?.removeTrailingZeros() ?? "", proteinGrams: proteinGrams?.removeTrailingZeros() ?? "", fatGrams: fatGrams?.removeTrailingZeros() ?? "", notes: notes)
    }
    
    mutating func update(from data: Data) {
        date = data.date
        bodyWeight = data.bodyWeight
        bodyFatPercentage = Double(data.bodyFatPercentage) ?? nil
        bmr = Int(data.bmr) ?? nil
        bmi = Double(data.bmi) ?? nil
        skeMuscleMass = data.skeMuscleMass
        totalCalories = Int(data.totalCalories) ?? nil
        carbohydrateGrams = Double(data.carbohydrateGrams) ?? nil
        proteinGrams = Double(data.proteinGrams) ?? nil
        fatGrams = Double(data.fatGrams) ?? nil
        notes = data.notes
    }
    
    init(id: UUID = UUID(), date: Date = Date(), bodyWeight: Weight? = nil, bodyFatPercentage: Double? = nil, bmr: Int? = nil, bmi: Double? = nil, skeMuscleMass: Weight? = nil, totalCalories: Int? = nil, carbohydrateGrams: Double? = nil, proteinGrams: Double? = nil, fatGrams: Double? = nil, notes: String = "") {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.bmr = bmr
        self.bmi = bmi
        self.skeMuscleMass = skeMuscleMass
        self.totalCalories = totalCalories
        self.carbohydrateGrams = carbohydrateGrams
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.notes = notes
    }
    
    static func build(from data: Data) -> JournalEntry {
        var entry = JournalEntry()
        entry.update(from: data)
        return entry
    }
    
    static func < (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.date < rhs.date
    }
}
