//
//  ExerciseDetailView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/13/21.
//

import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @Binding var exercise: Exercise
    
    @State private var exerciseData = Exercise.Data()
    @State private var showingChart = true
    @State private var grapherRerenderID: UUID = UUID()
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(exercise.tags, id: \.self) { tag in
                        TagBubble(tagName: tag)
                    }
                }
            }.padding(.horizontal)
            List {
                if showingChart {
                    Grapher(exercise: exercise)
                } else {
                    InfoSection
                }
                PastRecordViewer(exercise: exercise)
            }.listStyle(GroupedListStyle())
        }
        .onAppear {
            if exercise.mode == .Routine {
                showingChart = false
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarItems(trailing: NavBarButtons)
        .fullScreenCover(isPresented: $stateManager.editingExercise) {
            NavigationView {
                ExerciseEditView(exerciseData: $exerciseData)
                    .navigationBarItems(leading: Button("Cancel") {
                        stateManager.dismissExerciseEditing()
                    }, trailing: HStack {
                        Button(action:{
                            exerciseData.enabled.toggle()
                        }) {
                            Image(systemName: exerciseData.enabled ? "eye" : "eye.slash")
                                .foregroundColor(exerciseData.enabled ? .none : .red)
                        }
                        .padding(.trailing)
                        Button("Save") {
                            stateManager.dismissExerciseEditing()
                            exercise.update(from: exerciseData)
                        }.disabled(!stateManager.editExerciseChangesMade || stateManager.editExerciseNameEmpty)
                    })
                    .navigationTitle("Edit Exercise")
            }
            .environmentObject(data)
            .environmentObject(stateManager)
        }
    }
    
    private var NavBarButtons: some View {
        HStack(spacing: 10) {
            Button(action: {showingChart.toggle()}) {
                Image(systemName: showingChart ? "list.dash" : "waveform.path.ecg.rectangle")
            }.isHidden(exercise.mode == .Routine, remove: true)
            
            Button("Edit") {
                exerciseData = exercise.data
                stateManager.editingExercise = true
            }
        }
    }
    
    private var InfoSection: some View {
        Section (header: Text("Info"), footer: FooterWarning) {
            ListRowTextView(title: "Mode", value: exercise.mode.disp())
            if exercise.enabled {
                switch exercise.mode {
                case .Weight:
                    ListRowTextView(title: "Default Weight/Reps", value: "\(exercise.defaultWeight.disp()) × \(exercise.defaultReps)")
                    ListRowTextView(title: "Default Rest Time", value: exercise.defaultRestTime.isZero() ? "Disabled" : exercise.defaultRestTime.dispText())
                case .Timed:
                    ListRowTextView(title: "Default Time", value: exercise.defaultTime.dispText())
                    ListRowTextView(title: "Default Rest Time", value: exercise.defaultRestTime.isZero() ? "Disabled" : exercise.defaultRestTime.dispText())
                default:
                    EmptyView()
                }
                
                ListRowTextView(title: "Notes", value: exercise.notes)
            }
        }
    }
    
    private var FooterWarning: some View {
        Text("This exercise is currently hidden. Only past records are available.")
            .isHidden(exercise.enabled, remove: true)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseDetailView(exercise: .constant(Category.sampleData[0].exercises[0]))
                .environmentObject(MGBData())
                .environmentObject(StateManager())
        }
    }
}
