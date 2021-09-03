//
//  AppConfigurations.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/12/21.
//

import Foundation

struct AppConfiguration: Codable {
    var soundOn: Bool = true
    var weightLogDisplayMode: LogDisplayMode = .showAll
    var weightLogDisplayModeInExerciseView: LogDisplayMode = .showMaxIntensity
    var weightLogChartMode: LogDisplayMode = .showMaxIntensity
    var weightLogChartDefaultUnit: Weight.Unit = .KG
    var weightShowBest: Bool = true
    var timedLogDisplayMode: LogDisplayMode = .showAll
    var timedLogDisplayModeInExerciseView: LogDisplayMode = .showMaxIntensity
    var timedLogChartMode: LogDisplayMode = .showMaxIntensity
    var timedLogChartDefaultUnit: Time.Component = .MIN
    var timedShowBest: Bool = true
    var dateDisplayMode: DateDisplayMode = .textMedium
    var calendarDisplayContinuous: Bool = false
    
    mutating func resetAll() {
        soundOn = true
        weightLogDisplayMode = .showAll
        weightLogDisplayModeInExerciseView = .showMaxIntensity
        weightLogChartMode = .showMaxIntensity
        weightLogChartDefaultUnit = .KG
        weightShowBest = true
        timedLogDisplayMode = .showAll
        timedLogDisplayModeInExerciseView = .showMaxIntensity
        timedLogChartMode = .showMaxIntensity
        timedLogChartDefaultUnit = .MIN
        timedShowBest = true
        dateDisplayMode = .textMedium
        calendarDisplayContinuous = false
    }
    
    enum LogDisplayMode: Int, Codable {
        case showAll
        case showFirst
        case showLast
        case showMaxIntensity
        case showVolume
        
        func disp() -> String {
            switch self {
            case .showFirst:
                return "First Sets"
            case .showLast:
                return "Last Sets"
            case .showVolume:
                return "Training Volume"
            case .showMaxIntensity:
                return "Max Intensity"
            default:
                return ""
            }
        }
    }
    
    enum DateDisplayMode: Int, Codable {
        case textShort
        case textMedium
        case textLong
        case numeric
    }
}
