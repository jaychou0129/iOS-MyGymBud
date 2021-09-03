//
//  Units.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/7/21.
//

import Foundation

struct Weight: Codable, Hashable, Comparable {
    
    var value: Double
    var unit: Self.Unit
    
    init(_ value: Double = 0.0, _ unit: Self.Unit = Self.Unit.KG) {
        self.value = value
        self.unit = unit
    }
    
    func disp() -> String {
        return "\(self.value.removeTrailingZeros()) \(self.unit.disp())"
    }
    
    func valueInUnit(_ unit: Self.Unit = Self.Unit.KG) -> Double {
        if self.unit == unit {
            return self.value
        }
        if unit == .KG {
            return self.value / 2.20462
        } else {
            return self.value * 2.20462
        }
    }
    
    mutating func update(value: String) {
        self.value = Double(value) ?? 0.0
    }
    
    mutating func update(unit: String) {
        self.unit = Self.Unit(from: unit)
    }
    
    static func + (lhs: Weight, rhs: Weight) -> Weight {
        let workingUnit = lhs.unit
        return Weight(lhs.valueInUnit(workingUnit) + rhs.valueInUnit(workingUnit), workingUnit)
    }
    
    static func += (lhs: inout Weight, rhs: Weight) {
        lhs = lhs + rhs
    }
    
    static func * (lhs: Weight, rhs: Double) -> Weight {
        return Weight(lhs.value * rhs, lhs.unit)
    }
    
    static func * (lhs: Weight, rhs: Int) -> Weight {
        return Weight(lhs.value * Double(rhs), lhs.unit)
    }
    
    static func *= (lhs: inout Weight, rhs: Double) {
        lhs = lhs * rhs
    }
    static func *= (lhs: inout Weight, rhs: Int) {
        lhs = lhs * rhs
    }
    
    static func < (lhs: Weight, rhs: Weight) -> Bool {
        let workingUnit = lhs.unit
        return lhs.valueInUnit(workingUnit) < rhs.valueInUnit(workingUnit)
    }
}

struct Time: Codable, Hashable, Comparable {
    
    var value: Int // in seconds
    
    func isZero() -> Bool {
        return self.value == 0
    }
    
    init (minutes: Int = 0, seconds: Int = 0) {
        self.value = minutes * 60 + seconds
    }
    
    static func + (lhs: Time, rhs: Time) -> Time {
        return Time(seconds: lhs.value + rhs.value)
    }
    static func += (lhs: inout Time, rhs: Time) {
        lhs = lhs + rhs
    }
    
    static func * (lhs: Time, rhs: Int) -> Time {
        return Time(seconds: lhs.value * rhs)
    }

    static func *= (lhs: inout Time, rhs: Int) {
        lhs = lhs * rhs
    }
    
    func dispText(longFormat: Bool = false) -> String {
        if self.value % 60 != 0 || self.value == 0 {
            return longFormat ? (self.value == 1 ? "\(self.value) second" : "\(self.value) seconds") : "\(self.value) s"
        } else {
            return longFormat ? (self.value / 60 == 1 ? "\(self.value / 60) minute" : "\(self.value / 60) minutes") : "\(self.value / 60) min"
        }
    }
    
    func dispTimer() -> String {
        let min: Int = self.value / 60
        let sec: Int = self.value % 60
        
        return String(format: "%02d : %02d", min, sec)
    }
    
    func component(_ comp: Self.Component) -> String {
        if comp == .MIN {
            return String(format: "%02d", self.value / 60)
        }
        if comp == .SEC {
            return String(format: "%02d", self.value % 60)
        }
        return ""
    }
    
    mutating func update(seconds: String) {
        self.value = Int(seconds) ?? 0
    }
    
    mutating func update(timerString raw: String) {
        let timeArray = raw.split(separator: ":", omittingEmptySubsequences: false)
        
        let min: Int = Int(timeArray[0].trimmingCharacters(in: .whitespaces)) ?? 0
        let sec: Int = Int(timeArray[1].trimmingCharacters(in: .whitespaces)) ?? 0
        
        self.value = min * 60 + sec
    }
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Weight {
    enum Unit: Int, Codable {
        case KG
        case LBS
        
        func disp() -> String {
            switch self {
            case .KG:
                return "kg"
            default:
                return "lbs"
            }
        }
        
        init(from unitName: String) {
            switch unitName.lowercased() {
            case "lbs":
                self = .LBS
            default:
                self = .KG
            }
        }
        
        static var dispList: [String] {
            ["kg", "lbs"]
        }
    }
}

extension Time {
    enum Component: Int, Codable {
        case MIN
        case SEC
        
        func disp() -> String {
            switch self {
            case .MIN:
                return "min"
            default:
                return "sec"
            }
        }
    }
    
    func inUnit(_ unit: Component) -> Double {
        if unit == .MIN {
            return Double(self.value) / 60.0
        }
        return Double(self.value)
    }
}
