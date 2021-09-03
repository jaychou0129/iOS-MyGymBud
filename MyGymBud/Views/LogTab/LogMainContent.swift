//
//  LogMainContent.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct LogMainContent: View {
    
    let log: Log
    let mode: Mode
    let displayMode: AppConfiguration.LogDisplayMode
    
    var body: some View {
        VStack {
            switch mode {
            case .Weight:
                WeightMainContent
            case .Timed:
                TimedMainContent
            case .Routine:
                RoutineMainContent
            }
        }
        .padding(.top, 1.0)
    }
    
    private var WeightMainContent: some View {
        Group {
            switch displayMode {
            case .showAll:
                ForEach(log.weightLogs, id: \.self) { wLog in
                    HStack (alignment: .top) {
                        Text(wLog.weight.disp()).bold()
                        VStack {
                            ForEach(wLog.reps, id: \.self) { rep in
                                Text(rep.disp())
                            }
                        }
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showFirst:
                if let firstWeightLog = log.weightLogs.first {
                    if let firstRep = firstWeightLog.reps.first {
                        HStack (alignment: .top) {
                            Text(firstWeightLog.weight.disp()).bold()
                            Text(firstRep.disp())
                        }.padding(.top, 0.5).padding(.leading, 12.0)
                    }
                }
            case .showLast:
                if let lastWeightLog = log.weightLogs.last {
                    if let lastRep = lastWeightLog.reps.last {
                        HStack (alignment: .top) {
                            Text(lastWeightLog.weight.disp()).bold()
                            Text(lastRep.disp())
                        }.padding(.top, 0.5).padding(.leading, 12.0)
                    }
                }
            case .showMaxIntensity:
                if let maxWeightLog = log.maxWeightLog {
                    HStack (alignment: .top) {
                        Text(maxWeightLog.weight.disp()).bold()
                        VStack {
                            ForEach(maxWeightLog.reps, id: \.self) { rep in
                                Text(rep.disp())
                            }
                        }
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showVolume:
                HStack (alignment: .top) {
                    Text("Volume: ").bold()
                    Text("\(log.weightVolume.disp())")
                }.padding(.top, 0.5).padding(.leading, 12.0)
            }
        }
    }
    
    private var TimedMainContent: some View {
        Group {
            switch displayMode {
            case .showAll:
                ForEach(log.timedLogs, id: \.self) { tLog in
                    HStack (alignment: .top) {
                        Text(tLog.time.dispText()).bold()
                        Text(" × \(tLog.sets)")
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showFirst:
                if let firstTimedLog = log.timedLogs.first {
                    HStack (alignment: .top) {
                        Text(firstTimedLog.time.dispText()).bold()
                        Text(" × \(firstTimedLog.sets)")
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showLast:
                if let lastTimedLog = log.timedLogs.last {
                    HStack (alignment: .top) {
                        Text(lastTimedLog.time.dispText()).bold()
                        Text(" × \(lastTimedLog.sets)")
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showMaxIntensity:
                if let maxTimedLog = log.maxTimedLog {
                    HStack (alignment: .top) {
                        Text(maxTimedLog.time.dispText()).bold()
                        Text(" × \(maxTimedLog.sets)")
                    }.padding(.top, 0.5).padding(.leading, 12.0)
                }
            case .showVolume:
                HStack (alignment: .top) {
                    Text("Training Volume: ").bold()
                    Text("\(log.timedVolume.dispText())")
                }.padding(.top, 0.5).padding(.leading, 12.0)
            }
        }
    }
    
    private var RoutineMainContent: some View {
        HStack (alignment: .top) {
            Text("Total reps: ").bold()
            Text("\(log.routineLogs)")
        }.padding(.top, 0.5).padding(.leading, 12.0)
    }
}
