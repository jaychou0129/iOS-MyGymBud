//
//  NewLogExerciseView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/27/21.
//

import SwiftUI

struct NewLogExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @Binding var exercise: Exercise
    let date: Date
    var editingLog: Log?
    
    @StateObject private var config = LogConfiguration()
    @StateObject private var timerManager = TimerManager()
    @State private var temporaryLog = Log.Data()
    @State private var viewPastRecords = false
    
    var body: some View {
        VStack {
            List {
                InfoSection
                if exercise.mode != .Routine {
                    Section (header: Text("Logs")) {
                        if exercise.mode == .Weight {
                            WeightLogs
                        } else {
                            TimedLogs
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            if exercise.mode != .Routine {
                Divider()
                TimerView(log: $temporaryLog, mode: exercise.mode)
                    .environmentObject(config)
                    .environmentObject(timerManager)
            }
            
        }
        .navigationTitle(temporaryLog.date.disp(data.appConfig.dateDisplayMode))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel", action: {
                if editingLog == nil {
                    stateManager.dismissNewLog()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }),
            trailing: TrailingButtons)
        .onAppear {
            
            config.initialize(fromExercise: exercise)
            if let editingLog = editingLog {
                temporaryLog = editingLog.data
            } else {
                temporaryLog.eID = exercise.id
                temporaryLog.date = date
            }
        }
        .onDisappear(perform: timerManager.stop)
        .fullScreenCover(isPresented: $viewPastRecords) {
            ExerciseInspector(exercise: exercise).environmentObject(data)
        }
        .sheet(isPresented: $stateManager.presentingNewLogConfigSheet) {
            NewLogConfigView(exercise: $exercise)
                .environmentObject(config)
                .onDisappear {
                    if timerManager.mode == .paused && timerManager.secondsRemaining > 0 {
                        timerManager.start(soundOn: data.appConfig.soundOn)
                    }
                }
        }
    }
    
    private var InfoSection: some View {
        Section(header: Text("INFO")) {
            if editingLog == nil {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    ListRowComponentView(title: "Exercise") {
                        Text(exercise.name)
                        Image(systemName: "chevron.right")
                    }
                }
            } else {
                ListRowTextView(title: "Exercise", value: exercise.name)
            }
            
            if exercise.mode != .Routine {
                Button(action: {
                    stateManager.presentingNewLogConfigSheet = true
                }) {
                    ListRowComponentView(title: "Rest Time") {
                        Text(config.restTime.isZero() ? "Disabled" : config.restTime.dispTimer())
                    }
                }
            } else {
                ListRowComponentView(title: "Reps: ") {
                    Stepper("\(temporaryLog.routineLogs)", value: $temporaryLog.routineLogs, in: 1...100)
                }
            }
            
            ListRowComponentView(title: "Notes") {
                TextField("", text: $temporaryLog.notes)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var WeightLogs: some View {
        ForEach(temporaryLog.weightLogs.indices, id: \.self) { logIndex in
            let log = temporaryLog.weightLogs[logIndex]
            HStack {
                Text(log.weight.disp()).bold()
                VStack {
                    ForEach (log.reps.indices, id: \.self) { repIndex in
                        let rep = log.reps[repIndex]
                        
                        ListRowComponentView(title: rep.disp()) {
                            Stepper("", value: $temporaryLog.weightLogs[logIndex].reps[repIndex].sets, in: 1...100).labelsHidden()
                        }
                    }
                }
            }
            .padding(.trailing)
        }
    }
    
    private var TimedLogs: some View {
        ForEach(temporaryLog.timedLogs.indices, id: \.self) { logIndex in
            let log = temporaryLog.timedLogs[logIndex]
            HStack {
                Text(log.time.dispText()).bold()
                Text(" × \(log.sets)")
                Spacer()
                Stepper("", value: $temporaryLog.timedLogs[logIndex].sets, in: 1...100).labelsHidden()
            }
        }
    }
    
    private var TrailingButtons: some View {
        HStack {
            if editingLog == nil {
                Button(action: { viewPastRecords = true }) {
                    Image(systemName: "doc.text.magnifyingglass")
                }
            }
        
            Button("Done") {
                if let editingLog = editingLog {
                    data.updateLog(log: editingLog, data: temporaryLog)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    data.newLog(date: date, data: temporaryLog)
                    stateManager.dismissNewLog()
                }
            }.disabled(exercise.mode != .Routine && temporaryLog.timedLogs.isEmpty && temporaryLog.weightLogs.isEmpty)
        }
    }
}
