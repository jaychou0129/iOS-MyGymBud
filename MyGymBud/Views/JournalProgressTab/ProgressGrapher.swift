//
//  ProgressGrapher.swift
//  MyGymBud
//
//  Created by Jay Chou on 8/1/21.
//

import SwiftUI
import Sliders

struct ProgressGrapher: View {
    @EnvironmentObject var data: MGBData
    
    var viewMode: ViewModeKey = .BodyWeight
    
    @State private var weightUnit: Weight.Unit = .KG
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
        Section(header: Text(viewMode.inString)) {
            if dataPoints.count < 3 {
                VStack(alignment: .center, spacing: 20) {
                    Text("Not enough data").font(.callout)
                    Text("At least three past records are needed to generate graph.").font(.caption)
                }
                .frame(height: 300)
            } else {
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Text("Unit: \(weightUnit.disp())")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .onTapGesture(perform: toggleUnit)
                    }.isHidden(viewMode != .BodyWeight && viewMode != .SkeMuscleMass, remove: true)
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
        .onChange(of: viewMode) { _ in
            updateDataPoints()
        }
        .onChange(of: data.appConfig.dateDisplayMode) { _ in
            updateDataPoints()
        }
        .onChange(of: data.journal) { _ in
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
        weightUnit = (weightUnit == .KG) ? .LBS : .KG
        updateDataPoints()
    }
    
    private func updateDataPoints() {
        let dateDisplayMode = data.appConfig.dateDisplayMode
        let logs = data.journal.sorted()
        
        switch viewMode {
        case .BodyWeight:
            let saveLogs = logs.filter {$0.bodyWeight != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.bodyWeight!.valueInUnit(weightUnit))}
        case .BodyFatPercentage:
            let saveLogs = logs.filter {$0.bodyFatPercentage != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.bodyFatPercentage!)}
        case .BMR:
            let saveLogs = logs.filter {$0.bmr != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), Double($0.bmr!))}
        case .BMI:
            let saveLogs = logs.filter {$0.bmi != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), Double($0.bmi!))}
        case .SkeMuscleMass:
            let saveLogs = logs.filter {$0.skeMuscleMass != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.skeMuscleMass!.valueInUnit(weightUnit))}
        case .TotalCalories:
            let saveLogs = logs.filter {$0.totalCalories != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), Double($0.totalCalories!))}
        case .Carbohydrates:
            let saveLogs = logs.filter {$0.carbohydrateGrams != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.carbohydrateGrams!)}
        case .Proteins:
            let saveLogs = logs.filter {$0.proteinGrams != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.proteinGrams!)}
        case .Fats:
            let saveLogs = logs.filter {$0.fatGrams != nil}
            dataPoints = saveLogs.map {($0.date.disp(dateDisplayMode), $0.fatGrams!)}
        }
        
        
        print("dataPointsCount: \(dataPoints.count)")
    }
    
    enum ViewModeKey: String, CaseIterable  {
        case BodyWeight = "Body Weight"
        case BodyFatPercentage = "Body Fat %"
        case BMR = "BMR"
        case BMI = "BMI"
        case SkeMuscleMass = "Ske. Muscle Mass"
        case TotalCalories = "Total Calories"
        case Carbohydrates = "Carbohydrates"
        case Proteins = "Proteins"
        case Fats = "Fats"
        
        var inString: String {
            return self.rawValue
        }
    }
}



struct ProgressGrapher_Previews: PreviewProvider {
    static var previews: some View {
        ProgressGrapher()
    }
}
