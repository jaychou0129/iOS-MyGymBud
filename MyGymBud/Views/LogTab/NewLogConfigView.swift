//
//  NewLogConfigView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/8/21.
//

import SwiftUI

struct NewLogConfigView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var config: LogConfiguration
    @EnvironmentObject var data: MGBData
    @Binding var exercise: Exercise
    
    @State private var restTimerEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section (header: Text("Exercise Setting")) {
                    if exercise.mode == .Weight {
                        WeightRepsPicker(weight: $config.weight, reps: $config.reps, collapsible: false)
                        if exercise.defaultWeight != config.weight || exercise.defaultReps != config.reps {
                            Button("Set as default") {
                                exercise.defaultWeight = config.weight
                                exercise.defaultReps = config.reps
                            }
                        }
                    } else {
                        TimePicker(time: $config.time, collapsible: false)
                        if exercise.defaultTime != config.time {
                            Button("Set as default") {
                                exercise.defaultTime = config.time
                            }
                        }
                    }
                }
                
                Section (header: Text("Rest Timer")) {
                    Toggle("Enabled", isOn: $restTimerEnabled)
                    if restTimerEnabled {
                        TimePicker(time: $config.restTime, collapsible: false)
                        if exercise.defaultRestTime != config.restTime {
                            Button("Set as default") {
                                exercise.defaultRestTime = config.restTime
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if config.restTime.isZero() {
                restTimerEnabled = false
            } else {
                restTimerEnabled = true
            }
        }
        .onChange(of: restTimerEnabled) { _ in
            if !restTimerEnabled {
                config.restTime = Time()
            }
        }
    }
}

struct NewLogConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NewLogConfigView(exercise: .constant( Category.sampleData[0].exercises[1]))
            .environmentObject(LogConfiguration())
    }
}
