//
//  ExerciseEditView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/13/21.
//

import SwiftUI

struct ExerciseEditView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @Binding var exerciseData: Exercise.Data
    
    @State private var currentCategoryName: String = ""
    @State private var moveToSelected: String = ""
    @State private var modeSelected: String = ""
    @State private var restTimerEnabled = false
    @State private var showingClearLogWarning = false
    @State private var showingDeleteExerciseWarning = false
    @State private var tagsTextField = ""
    @State private var showTagsEditor = false
    @State private var weight: Weight? = nil
    
    var body: some View {
        List {
            InfoSection
            
            if !stateManager.creatingNewExercise {
                ActionButtons
            }
        }
        .onChange(of: exerciseData) { _ in
            stateManager.editExerciseChangesMade = true
            stateManager.editExerciseNameEmpty = exerciseData.name.isEmpty
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(isPresented: $showTagsEditor) {
            TagsEditor(tags: $exerciseData.tags)
        }
        .onAppear {
            stateManager.editExerciseChangesMade = false
            modeSelected = exerciseData.mode.disp()
            
            if !exerciseData.defaultRestTime.isZero() {
                restTimerEnabled = true
            }
            
            if let categoryID = stateManager.presentingCategoryID,
               let category = data.findCategory(id: categoryID) {
                currentCategoryName = category.name
            }
        }
    }
    
    private func moveExercise(destination: String) {
        let categoryID = stateManager.presentingCategoryID!
        let exerciseID = stateManager.presentingExerciseID!
        
        stateManager.dismissExercise()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                data.moveExercise(fromCategoryID: categoryID, id: exerciseID, toCategoryName: moveToSelected)
            }
        }
    }
    
    private func clearLogs() {
        let exerciseID = stateManager.presentingExerciseID!
        data.clearLogs(exerciseID: exerciseID)
        stateManager.dismissExerciseEditing()
    }
    
    private func deleteExercise() {
        let categoryID = stateManager.presentingCategoryID!
        let exerciseID = stateManager.presentingExerciseID!
        
        stateManager.dismissExercise()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                data.deleteExercise(categoryID: categoryID, id: exerciseID)
            }
        }
    }
    
    private var FooterWarning: some View {
        Text("This exercise is currently hidden. Tap the eye button to start editing.")
            .isHidden(exerciseData.enabled, remove: true)
    }
    
    private var InfoSection: some View {
        Section (header: Text("Info"), footer: FooterWarning) {
            if exerciseData.enabled {
                ListRowComponentView(title: "Name") {
                    TextField("Enter Name", text: $exerciseData.name)
                        .multilineTextAlignment(.trailing)
                }
            } else {
                ListRowTextView(title: "Name", value: exerciseData.name)
            }
            
            // is in creating mode
            if stateManager.creatingNewExercise {
                Picker("Mode", selection: $modeSelected) {
                    Text("Weight").tag("Weight")
                    Text("Timed").tag("Timed")
                    Text("Routine").tag("Routine")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: modeSelected) { _ in
                    exerciseData.mode = Mode(from: modeSelected)
                }
            } else {
                ListRowTextView(title: "Mode", value: exerciseData.mode.disp())
            }

            if exerciseData.enabled {
                if exerciseData.mode != .Routine {
                    if exerciseData.mode == .Weight {
                        WeightRepsPicker(label: "Default Weight/Reps", weight: $exerciseData.defaultWeight, reps: $exerciseData.defaultReps)
                    } else if exerciseData.mode == .Timed {
                        TimePicker(label: "Default Time", time: $exerciseData.defaultTime)
                    }
                    
                    Toggle("Rest Timer", isOn: $restTimerEnabled)
                    .onChange(of: restTimerEnabled) { _ in
                        if !restTimerEnabled {
                            exerciseData.defaultRestTime = Time()
                        }
                    }

                    if restTimerEnabled {
                        TimePicker(label: "", time: $exerciseData.defaultRestTime)
                    }
                }
                
                NotesSection
                
            }
        }
    }
    
    private var NotesSection: some View {
        Group {
            // Notes & Tags
            Button(action: {
                showTagsEditor = true
            }) {
                ListRowComponentView(title: "Tags") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(exerciseData.tags, id: \.self) { tag in
                                TagBubble(tagName: tag)
                            }
                        }
                    }.onTapGesture {
                        showTagsEditor = true
                    }
                }
            }
            
            TextField("Notes", text: $exerciseData.notes)
        }
    }
    
    private var ActionButtons: some View {
        Section {
            ListRowComponentView(title: "Move To") {
                Picker("Select...", selection: $moveToSelected) {
                    ForEach(data.listOfCategoryNames.filter{$0 != currentCategoryName}, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: moveToSelected, perform: moveExercise)
            }
            Button(action: {
                showingClearLogWarning = true
            }) {
                Text("Clear all logs")
                    .foregroundColor(.red)
            }
            .actionSheet(isPresented: $showingClearLogWarning) {
                ActionSheet(title: Text("Warning"), message: Text("Clearing logs is permanent and cannot be undone."), buttons: [
                    .cancel(),
                    .destructive(Text("Clear logs"), action: clearLogs)
                ])
            }

            Button(action: {
                showingDeleteExerciseWarning = true
            }) {
                Text("Delete exercise forever")
                    .foregroundColor(.red)
            }
            .actionSheet(isPresented: $showingDeleteExerciseWarning) {
                ActionSheet(title: Text("Warning"), message: Text("All previous logs of this exercise will be deleted along with the exercise, and this cannot be undone."), buttons: [
                    .cancel(),
                    .destructive(Text("Delete exercise forever"), action: deleteExercise)
                ])
            }
        }
    }
}

struct ExerciseEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseEditView(exerciseData: .constant(Category.sampleData[0].exercises[1].data))
            .environmentObject(MGBData())
            .environmentObject(StateManager())
    }
}
