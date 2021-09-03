//
//  Grapher.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI
import Sliders

struct Grapher: View {
    @EnvironmentObject var data: MGBData
    
    let exercise: Exercise
    
    @State private var weightUnit: Weight.Unit = .KG
    @State private var timedUnit: Time.Component = .MIN
    @State private var dataPoints: [(String, Double)] = [] {
        didSet {
            if dataPoints.count > 0 {
                displayIndexRange = displayIndexRange.clamped(to: dataPoints.startIndex ... dataPoints.endIndex-1)
            }
        }
    }
    @State private var displayIndexRange = 0...1
    @State private var oldRange = 0...1
    
    var body: some View {
        Section(header: Text("Progress")) {
            if dataPoints.count < 3 {
                VStack(alignment: .center, spacing: 20) {
                    Text("Not enough data").font(.callout)
                    Text("At least three past records are needed to generate graph.").font(.caption)
                }
                .frame(height: 300)
            } else {
                VStack(alignment: .trailing) {
                    HStack {
                        let title = (exercise.mode == .Weight) ? data.appConfig.weightLogChartMode.disp() : data.appConfig.timedLogChartMode.disp()
                        Text(title).font(.caption)
                        Spacer()
                        Text(exercise.mode == .Weight ? "Unit: \(weightUnit.disp())" : "Unit: \(timedUnit.disp())")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .onTapGesture(perform: toggleUnit)
                    }
                    ZStack(alignment: .bottomTrailing) {
                        LineView(data: Array(dataPoints[displayIndexRange]), valueSpecifier: "%.1f", legendSpecifier: "%.0f")
                            .frame(height: 300)
                            .padding(.horizontal)
                            .offset(y: 30)
                        RangeSliderView.offset(y: -130).isHidden(dataPoints.count < 5)
                    }
                    .frame(height: 280)
                }
                .frame(height: 300)
                .listRowBackground(Color("Background"))
            }
        }
        .onAppear {
            weightUnit = data.appConfig.weightLogChartDefaultUnit
            timedUnit = data.appConfig.timedLogChartDefaultUnit
            updateDataPoints()
            if dataPoints.count > 0 {
                displayIndexRange = dataPoints.startIndex ... dataPoints.endIndex-1
            }
        }
        .onChange(of: displayIndexRange) { _ in
            if displayIndexRange.upperBound - displayIndexRange.lowerBound < 2 {
                displayIndexRange = oldRange
            }
            oldRange = displayIndexRange
        }
        .onChange(of: data.appConfig.weightLogDisplayMode) { _ in
            updateDataPoints()
        }
        .onChange(of: data.appConfig.timedLogDisplayMode) { _ in
            updateDataPoints()
        }
        .onChange(of: data.appConfig.dateDisplayMode) { _ in
            updateDataPoints()
        }
        .onChange(of: data.logs) { _ in
            updateDataPoints()
        }
    }
    
    private var RangeSliderView: some View {
        VStack {
            RangeSlider(range: $displayIndexRange, in: dataPoints.startIndex...dataPoints.endIndex-1, step: 1)
                .padding()
                .rangeSliderStyle(
                    HorizontalRangeSliderStyle(
                        track:
                            HorizontalRangeTrack(
                                view: Capsule().foregroundColor(Color("AccentColor"))
                            )
                            .background(Capsule().foregroundColor(Color("AccentColor").opacity(0.25)))
                            .frame(height: 3),
                        lowerThumb: Circle().foregroundColor(.accentColor).frame(width: 10),
                        upperThumb: Circle().foregroundColor(.accentColor).frame(width: 10),
                        options: .forceAdjacentValue
                    )
            )
        }
    }
    
    private func toggleUnit() {
        if exercise.mode == .Weight {
            weightUnit = (weightUnit == .KG) ? .LBS : .KG
        } else if exercise.mode == .Timed {
            timedUnit = (timedUnit == .MIN) ? .SEC : .MIN
        }
        
        updateDataPoints()
    }
    
    private func updateDataPoints() {
        let weightDisplayMode = data.appConfig.weightLogChartMode
        let timedDisplayMode = data.appConfig.timedLogChartMode
        let dateDisplayMode = data.appConfig.dateDisplayMode
        let logs = data.logs.filter {$0.eID == exercise.id}.sorted()
        
        if exercise.mode == .Weight {
            switch weightDisplayMode {
            case .showFirst:
                let safeLogs = logs.filter {$0.weightLogs.first != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.weightLogs.first!.weight.valueInUnit(weightUnit))}
            case .showLast:
                let safeLogs = logs.filter {$0.weightLogs.last != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.weightLogs.last!.weight.valueInUnit(weightUnit))}
            case .showVolume:
                dataPoints = logs.map {($0.date.disp(dateDisplayMode), $0.weightVolume.valueInUnit(weightUnit))}
            default:
                let safeLogs = logs.filter {$0.maxWeightLog != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.maxWeightLog!.weight.valueInUnit(weightUnit))}
            }
        } else {
            switch timedDisplayMode {
            case .showFirst:
                let safeLogs = logs.filter {$0.timedLogs.first != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.timedLogs.first!.time.inUnit(timedUnit))}
            case .showLast:
                let safeLogs = logs.filter {$0.timedLogs.last != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.timedLogs.last!.time.inUnit(timedUnit))}
            case .showVolume:
                dataPoints = logs.map {($0.date.disp(dateDisplayMode), $0.timedVolume.inUnit(timedUnit))}
            default:
                let safeLogs = logs.filter {$0.maxTimedLog != nil}
                dataPoints = safeLogs.map {($0.date.disp(dateDisplayMode), $0.maxTimedLog!.time.inUnit(timedUnit))}
            }
        }
        print("dataPointsCount: \(dataPoints.count)")
    }
}
